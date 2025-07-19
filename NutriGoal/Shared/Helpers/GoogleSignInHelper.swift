import Foundation
import FirebaseAuth
import GoogleSignIn
import UIKit

// MARK: - Google Sign-In Helper
final class GoogleSignInHelper {
    
    static func signIn(presenting: UIViewController) async throws -> AuthCredential {
        print("🟢 [GoogleSignInHelper] Starting Google sign-in flow")
        
        return try await withCheckedThrowingContinuation { continuation in
            // Get Firebase app configuration
            guard let app = FirebaseApp.app(),
                  let clientID = app.options.clientID else {
                print("❌ [GoogleSignInHelper] Firebase app or clientID not found")
                continuation.resume(throwing: AuthError.configurationError)
                return
            }
            
            // Configure Google Sign-In
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            
            // Start sign-in flow
            GIDSignIn.sharedInstance.signIn(withPresenting: presenting) { result, error in
                if let error = error {
                    print("❌ [GoogleSignInHelper] Google sign-in failed: \(error)")
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let result = result,
                      let idToken = result.user.idToken?.tokenString else {
                    print("❌ [GoogleSignInHelper] Failed to get ID token")
                    continuation.resume(throwing: AuthError.tokenError)
                    return
                }
                
                let accessToken = result.user.accessToken.tokenString
                print("✅ [GoogleSignInHelper] Got tokens, creating credential")
                
                // Create Firebase credential
                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: accessToken
                )
                
                continuation.resume(returning: credential)
            }
        }
    }
}

// MARK: - Auth Errors
enum AuthError: LocalizedError {
    case configurationError
    case tokenError
    case userCancelled
    
    var errorDescription: String? {
        switch self {
        case .configurationError:
            return "Authentication configuration error"
        case .tokenError:
            return "Failed to retrieve authentication token"
        case .userCancelled:
            return "User cancelled authentication"
        }
    }
} 