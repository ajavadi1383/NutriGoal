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
        print("🚀 [HeroViewModel] Navigating directly to onboarding...")
        router.to(.onboarding)
        print("✅ [HeroViewModel] Navigation command sent, current route: \(router.route)")
    }
} 