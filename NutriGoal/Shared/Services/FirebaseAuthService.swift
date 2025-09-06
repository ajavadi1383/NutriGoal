import Foundation
import FirebaseAuth
import UIKit

// MARK: - Firebase Auth Service Protocol
protocol FirebaseAuthService {
    func createUser(email: String, password: String) async throws -> AuthDataResult
    func signIn(email: String, password: String) async throws -> AuthDataResult
    func signOut() throws
    func getCurrentUser() -> User?
    func deleteCurrentUser() async throws
}

// MARK: - Firebase Auth Service Implementation
@MainActor
final class FirebaseAuthServiceImpl: FirebaseAuthService, ObservableObject {
    
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
    
    func getCurrentUser() -> User? {
        return Auth.auth().currentUser
    }
    
    func deleteCurrentUser() async throws {
        print("🗑️ [FirebaseAuthService] Deleting current user")
        guard let user = Auth.auth().currentUser else {
            throw FirebaseAuthError.noCurrentUser
        }
        
        do {
            try await user.delete()
            print("✅ [FirebaseAuthService] User deleted successfully")
        } catch {
            print("❌ [FirebaseAuthService] Delete user failed: \(error)")
            throw error
        }
    }
}

// MARK: - Firebase Auth Errors
enum FirebaseAuthError: LocalizedError {
    case noCurrentUser
    
    var errorDescription: String? {
        switch self {
        case .noCurrentUser:
            return "No authenticated user found"
        }
    }
}

// TODO: Register in Resolver container
// Resolver.register { FirebaseAuthServiceImpl() as FirebaseAuthService } 