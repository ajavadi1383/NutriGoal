import Foundation
import FirebaseAuth

protocol AuthManager {
    var currentUID: String? { get }
    var authStateStream: AsyncStream<User?> { get }
    func signInAnonymously() async throws
    func signOut() throws
} 