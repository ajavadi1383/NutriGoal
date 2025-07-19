import Foundation
import FirebaseAuth

protocol AuthManager {
    var currentUID: String? { get }
    var authStateStream: AsyncStream<User?> { get }
    func signInAnonymously() async throws
    func signOut() throws
}

final class FirebaseAuthManager: AuthManager {
    
    var currentUID: String? {
        Auth.auth().currentUser?.uid
    }
    
    var authStateStream: AsyncStream<User?> {
        AsyncStream { continuation in
            let handle = Auth.auth().addStateDidChangeListener { _, user in
                continuation.yield(user)
            }
            
            continuation.onTermination = { _ in
                Auth.auth().removeStateDidChangeListener(handle)
            }
        }
    }
    
    func signInAnonymously() async throws {
        let result = try await Auth.auth().signInAnonymously()
        guard result.user.uid.isEmpty == false else {
            throw AuthError.anonymousSignInFailed
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
}

enum AuthError: Error {
    case anonymousSignInFailed
    case signOutFailed
} 