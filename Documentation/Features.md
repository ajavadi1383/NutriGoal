# Features

Feature-level views and their ViewModels.

## Hero

- View: `HeroView(router: AppRouter)`
- ViewModel: `HeroViewModel`

Usage:

```swift
let router = AppRouter()
HeroView(router: router)
```

Action:
- `startTapped()` navigates to `.onboarding`.

---

## Authentication

- View: `AuthView(router: AppRouter)`
- ViewModel: `AuthViewModel`

Usage:

```swift
let router = AppRouter()
AuthView(router: router)
```

Key bindings and actions:
- `email`, `password`, `isFormValid`, `isLoading`
- `signUpTapped()`, `signInTapped()`, `skipTapped()`

Side effects:
- On success, routes to `.home`.
- Creates `UserProfile` from locally saved onboarding data when signing up.

---

## Onboarding

- View: `OnboardingView()` (inject `AppRouter` via `.environmentObject`)
- ViewModel: `OnboardingViewModel`

Usage:

```swift
let router = AppRouter()
OnboardingView()
  .environmentObject(router)
```

Key state:
- `page`, `birthDate`, `sex`, `heightCm`, `weightKg`, `activityLevel`, `target`, `weeklyPaceKg`, `dietType`, `lang`

Actions:
- `saveCurrentPageData()`: persists progress to `UserDefaults`
- `next()`: advances pages with animation
- `finish()`: saves final onboarding data locally and routes to `.auth`

---

## Home Dashboard

- View: `HomeDashboardView()`
- ViewModel: `HomeDashboardViewModel`

Usage:

```swift
HomeDashboardView()
```

Actions:
- `loadMeals()`: fetches today’s meals via `FirebaseService`

Composed components:
- `DashboardCard`, `MealRow`, `FloatingActionButton`

---

## Meal Logging

- View: `MealLoggingView()`
- ViewModel: `MealLoggingViewModel`

Usage:

```swift
MealLoggingView()
```

Key bindings:
- Photo: `selectedPhotoItem`, `selectedImage`, `isRecognizing`, `recognitionComplete`
- Form: `name`, `caloriesText`, `proteinText`, `carbsText`, `fatText`, `isSaving`

Actions:
- `loadImage()`: loads selected photo and triggers `recognise()`
- `recognise()`: AI recognition via `FoodRecognitionService`
- `saveTapped()`: saves meal and updates day stats via `FirebaseService`

Notifications:
- Posts `Notification.Name.mealAdded` after save.