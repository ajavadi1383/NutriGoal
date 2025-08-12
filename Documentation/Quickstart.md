# Quickstart

## Run the App

1. Open `NutriGoal.xcodeproj` in Xcode (iOS 17+)
2. Ensure `GoogleService-Info.plist` is configured and included in the target
3. Build and run on a simulator or device

The app entry is `NutriGoalApp` with Firebase configured:

```swift
@main
struct NutriGoalApp: App {
    init() { FirebaseApp.configure() }
    var body: some Scene { WindowGroup { ContentView() } }
}
```

Routing is handled by `AppRouter` in `ContentView`. Initial route is set to `.hero` for now.

To inject router into views that require it:

```swift
let router = AppRouter()
OnboardingView()
  .environmentObject(router)
```

## Configure OpenAI

- Add `OpenAI API Key` to `GoogleService-Info.plist`
- `AppConfig` reads it at runtime and uses `gpt-4o` for vision recognition

## Firebase

- Firebase is initialized by `FirebaseApp.configure()`
- Authentication and Firestore are used by the services documented in `APIs.md`