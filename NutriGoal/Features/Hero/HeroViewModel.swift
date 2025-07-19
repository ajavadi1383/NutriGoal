import Foundation
import SwiftUI

@MainActor
final class HeroViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let authManager: AuthManager
    private let router: AppRouter
    
    // MARK: - Published Properties
    @Published var isLoading = false
    
    // MARK: - Initialization
    init(authManager: AuthManager, router: AppRouter) {
        self.authManager = authManager
        self.router = router
    }
    
    // MARK: - Actions
    func startTapped() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Sign in anonymously if needed
            if authManager.currentUID == nil {
                try await authManager.signInAnonymously()
            }
            
            // Navigate to onboarding
            router.to(.onboarding)
            
        } catch {
            print("❌ [\(#function)] \(error.localizedDescription)")
        }
    }
} 