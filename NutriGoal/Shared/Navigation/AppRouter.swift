import SwiftUI

enum AppRoute {
    case hero
    case onboarding
    case home
}

@MainActor
final class AppRouter: ObservableObject {
    @Published var route: AppRoute = .hero
    
    func to(_ newRoute: AppRoute) {
        print("🧭 [AppRouter] Navigating from \(route) to \(newRoute)")
        route = newRoute
        print("✅ [AppRouter] Route updated to \(route)")
    }
} 