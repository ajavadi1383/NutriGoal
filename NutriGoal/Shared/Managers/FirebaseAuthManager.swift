import Foundation
import FirebaseAuth

final class FirebaseAuthManager: AuthManager, ObservableObject {
    
    @Published private(set) var currentUID: String?
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        // Initialize with current auth state
        self.currentUID = Auth.auth().currentUser?.uid
        
        // Attach state listener to update currentUID automatically
        self.authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUID = user?.uid
            }
        }
    }
    
    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
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
        guard !result.user.uid.isEmpty else {
            throw AuthError.anonymousSignInFailed
        }
        // currentUID will be automatically updated via state listener
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        // currentUID will be automatically updated via state listener
    }
}

enum AuthError: Error {
    case anonymousSignInFailed
    case signOutFailed
}

// MARK: - Resolver Registration
/*
 Paste this into your DI container file:
 
 Resolver.register { FirebaseAuthManager() as AuthManager }
*/ 