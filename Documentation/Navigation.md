# Navigation

The app uses a simple router to manage top-level routes.

## Routes

```swift
enum AppRoute {
    case hero
    case auth
    case onboarding
    case home
    case mainApp
}
```

## Router

```swift
@MainActor
final class AppRouter: ObservableObject {
    @Published var route: AppRoute = .hero
    func to(_ route: AppRoute)
}
```

Usage:

```swift
let router = AppRouter()
router.to(.onboarding)
```

Inject into views using `@EnvironmentObject` where needed:

```swift
OnboardingView()
    .environmentObject(router)
```

Notes:
- Navigation is driven by setting `router.route`.
- Feature ViewModels can receive `AppRouter` via init for navigation side effects.