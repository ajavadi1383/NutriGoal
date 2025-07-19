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
        print("🎯 [HeroViewModel] startTapped() called")
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Sign in anonymously if needed
            if authManager.currentUID == nil {
                print("🔐 [HeroViewModel] Signing in anonymously...")
                try await authManager.signInAnonymously()
                print("✅ [HeroViewModel] Anonymous sign-in successful, UID: \(authManager.currentUID ?? "nil")")
            } else {
                print("✅ [HeroViewModel] Already authenticated, UID: \(authManager.currentUID ?? "nil")")
            }
            
            // Navigate to onboarding
            print("🚀 [HeroViewModel] Navigating to onboarding...")
            router.to(.onboarding)
            print("✅ [HeroViewModel] Navigation command sent, current route: \(router.route)")
            
        } catch {
            print("❌ [\(#function)] \(error.localizedDescription)")
        }
    }
} 