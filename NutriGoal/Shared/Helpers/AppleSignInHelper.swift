import Foundation
import AuthenticationServices
import FirebaseAuth
import CryptoKit

// MARK: - Apple Sign-In Helper
final class AppleSignInHelper: NSObject {
    
    private var currentNonce: String?
    private var continuation: CheckedContinuation<AuthCredential, Error>?
    
    static func signIn() async throws -> AuthCredential {
        print("🍎 [AppleSignInHelper] Starting Apple sign-in flow")
        
        let helper = AppleSignInHelper()
        return try await helper.performSignIn()
    }
    
    private func performSignIn() async throws -> AuthCredential {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            
            // Generate nonce
            let nonce = randomNonceString()
            currentNonce = nonce
            
            // Create Apple ID authorization request
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(nonce)
            
            // Create and start authorization controller
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.performRequests()
            
            print("✅ [AppleSignInHelper] Authorization request started")
        }
    }
    
    // Generate random nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    // Hash nonce with SHA256
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AppleSignInHelper: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                print("❌ [AppleSignInHelper] Invalid state: A login callback was received, but no login request was sent.")
                continuation?.resume(throwing: AuthError.configurationError)
                return
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("❌ [AppleSignInHelper] Unable to fetch identity token")
                continuation?.resume(throwing: AuthError.tokenError)
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("❌ [AppleSignInHelper] Unable to serialize token string from data")
                continuation?.resume(throwing: AuthError.tokenError)
                return
            }
            
            // Create Firebase credential
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                          rawNonce: nonce,
                                                          fullName: appleIDCredential.fullName)
            
            print("✅ [AppleSignInHelper] Apple credential created successfully")
            continuation?.resume(returning: credential)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("❌ [AppleSignInHelper] Sign in with Apple errored: \(error)")
        continuation?.resume(throwing: error)
    }
} 