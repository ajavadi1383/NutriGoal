import Foundation
import SwiftUI

// TODO: Define Router protocol
protocol Router {
    func route(to destination: NavigationDestination)
}

enum NavigationDestination {
    case onboarding
}

@MainActor
final class HeroViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let authManager: AuthManager
    private let router: Router? = nil // TODO: real router
    
    // MARK: - Published Properties
    @Published var isLoading = false
    
    // MARK: - Initialization
    init(authManager: AuthManager) {
        self.authManager = authManager
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
            router?.route(to: .onboarding) // TODO: real router
            
        } catch {
            print("❌ [\(#function)] \(error.localizedDescription)")
        }
    }
} 