import SwiftUI

enum AppRoute {
    case hero
    case auth  
    case onboarding
    case home
    case mainApp
}

@MainActor
final class AppRouter: ObservableObject {
    @Published var route: AppRoute = .hero
    
    func to(_ route: AppRoute) {
        print("🧭 [AppRouter] Navigating to: \(route)")
        self.route = route
    }
} 