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
        route = newRoute
    }
} 