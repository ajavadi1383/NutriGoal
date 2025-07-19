import Foundation
import SwiftUI

// TODO: Define Router protocol for navigation
protocol Router {
    func route(to destination: NavigationDestination)
}

enum NavigationDestination {
    case onboarding
    case dashboard
}

@MainActor
final class HeroViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let authManager: AuthManager
    private let router: Router?
    
    // MARK: - Published Properties
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    // MARK: - Initialization
    init(authManager: AuthManager, router: Router? = nil) {
        self.authManager = authManager
        self.router = router
    }
    
    // MARK: - Actions
    func startTapped() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Check if user is already authenticated
            if authManager.currentUID == nil {
                try await authManager.signInAnonymously()
            }
            
            // Navigate to onboarding
            // TODO: Implement router navigation
            router?.route(to: .onboarding)
            
        } catch {
            showError = true
            errorMessage = "Failed to start your journey. Please try again."
            print("❌ [\(#function)] \(error.localizedDescription)")
        }
    }
    
    // MARK: - Error Handling
    func dismissError() {
        showError = false
        errorMessage = ""
    }
} 