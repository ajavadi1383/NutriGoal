import Foundation
import FirebaseAuth
import UIKit

// MARK: - Firebase Auth Service Protocol
protocol FirebaseAuthService {
    func createUser(email: String, password: String) async throws -> AuthDataResult
    func signIn(email: String, password: String) async throws -> AuthDataResult
    func signInWithGoogle(presenting: UIViewController) async throws -> AuthDataResult
    func signInWithApple() async throws -> AuthDataResult
    func signOut() throws
}

// MARK: - Firebase Auth Service Implementation
@MainActor
final class FirebaseAuthServiceImpl: FirebaseAuthService {
    
    func createUser(email: String, password: String) async throws -> AuthDataResult {
        print("🔐 [FirebaseAuthService] Creating user with email: \(email)")
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            print("✅ [FirebaseAuthService] User created successfully: \(result.user.uid)")
            return result
        } catch {
            print("❌ [FirebaseAuthService] Create user failed: \(error)")
            throw error
        }
    }
    
    func signIn(email: String, password: String) async throws -> AuthDataResult {
        print("🔐 [FirebaseAuthService] Signing in with email: \(email)")
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            print("✅ [FirebaseAuthService] Sign in successful: \(result.user.uid)")
            return result
        } catch {
            print("❌ [FirebaseAuthService] Sign in failed: \(error)")
            throw error
        }
    }
    
    func signInWithGoogle(presenting: UIViewController) async throws -> AuthDataResult {
        print("🔐 [FirebaseAuthService] Starting Google sign-in")
        do {
            let credential = try await GoogleSignInHelper.signIn(presenting: presenting)
            let result = try await Auth.auth().signIn(with: credential)
            print("✅ [FirebaseAuthService] Google sign-in successful: \(result.user.uid)")
            return result
        } catch {
            print("❌ [FirebaseAuthService] Google sign-in failed: \(error)")
            throw error
        }
    }
    
    func signInWithApple() async throws -> AuthDataResult {
        print("🔐 [FirebaseAuthService] Starting Apple sign-in")
        do {
            let credential = try await AppleSignInHelper.signIn()
            let result = try await Auth.auth().signIn(with: credential)
            print("✅ [FirebaseAuthService] Apple sign-in successful: \(result.user.uid)")
            return result
        } catch {
            print("❌ [FirebaseAuthService] Apple sign-in failed: \(error)")
            throw error
        }
    }
    
    func signOut() throws {
        print("🔐 [FirebaseAuthService] Signing out")
        do {
            try Auth.auth().signOut()
            print("✅ [FirebaseAuthService] Sign out successful")
        } catch {
            print("❌ [FirebaseAuthService] Sign out failed: \(error)")
            throw error
        }
    }
}

// TODO: Register in Resolver container
// Resolver.register { FirebaseAuthServiceImpl() as FirebaseAuthService } 