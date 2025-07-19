import Foundation
import FirebaseAuth

final class FirebaseAuthManager: AuthManager, ObservableObject {
    func signInAnonymously() async throws {
        return
    }
    
    
    
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
    
    func signOut() throws {
        try Auth.auth().signOut()
        // currentUID will be automatically updated via state listener
    }
}
// MARK: - Resolver Registration
/*
 Paste this into your DI container file:
 
 Resolver.register { FirebaseAuthManager() as AuthManager }
*/ 
