import FirebaseAuth
import Foundation

protocol FirebaseAuthService {
    func createUser(email: String, password: String) async throws
    func signIn(email: String, password: String) async throws
    func signOut() throws
}

final class FirebaseAuthServiceImpl: FirebaseAuthService {
    
    func createUser(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            print("✅ [FirebaseAuthService] User created successfully: \(result.user.uid)")
        } catch {
            print("❌ [FirebaseAuthService] Failed to create user: \(error.localizedDescription)")
            throw error
        }
    }
    
    func signIn(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            print("✅ [FirebaseAuthService] User signed in successfully: \(result.user.uid)")
        } catch {
            print("❌ [FirebaseAuthService] Failed to sign in: \(error.localizedDescription)")
            throw error
        }
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            print("✅ [FirebaseAuthService] User signed out successfully")
        } catch {
            print("❌ [FirebaseAuthService] Failed to sign out: \(error.localizedDescription)")
            throw error
        }
    }
}

// Resolver.register { FirebaseAuthServiceImpl() as FirebaseAuthService } 