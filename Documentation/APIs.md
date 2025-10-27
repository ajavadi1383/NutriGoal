# APIs

This reference documents service protocols, concrete implementations, and notable error types.

## FirebaseAuthService

Protocol methods:

```swift
protocol FirebaseAuthService {
    func createUser(email: String, password: String) async throws -> AuthDataResult
    func signIn(email: String, password: String) async throws -> AuthDataResult
    func signOut() throws
    func getCurrentUser() -> User?
    func deleteCurrentUser() async throws
}
```

Default implementation: `FirebaseAuthServiceImpl`.

Example:

```swift
let auth: FirebaseAuthService = FirebaseAuthServiceImpl()

// Sign up
let signUp = try await auth.createUser(email: "john@example.com", password: "secret123")
print("UID:", signUp.user.uid)

// Sign in
let signIn = try await auth.signIn(email: "john@example.com", password: "secret123")
print("UID:", signIn.user.uid)

// Get current user
let user = auth.getCurrentUser()

// Sign out
try auth.signOut()
```

Errors: operations surface FirebaseAuth errors; see console logs for diagnostics. Custom error: `FirebaseAuthError.noCurrentUser`.

---

## FirebaseService

Protocol methods:

```swift
protocol FirebaseService {
    func save(profile: UserProfile) async throws
    func deleteUserData(uid: String) async throws
    func save(meal: Meal, for date: Date) async throws
    func updateDayStats(for date: Date, adding meal: Meal) async throws
    func fetchMeals(for date: Date) async throws -> [Meal]
}
```

Default implementation: `FirebaseServiceImpl` (Firestore-backed).

Example:

```swift
let firebase: FirebaseService = FirebaseServiceImpl()

// Save profile
let profile = UserProfile(
    id: "uid123",
    email: "john@example.com",
    birthDate: Date(timeIntervalSince1970: 0),
    sex: "male",
    heightCm: 180,
    weightKg: 78.5,
    activityLevel: "3-4",
    target: "maintain",
    weeklyPaceKg: 0.5,
    goalDate: Calendar.current.date(byAdding: .month, value: 3, to: Date())!,
    dietType: "none",
    lang: "en",
    createdAt: Date()
)
try await firebase.save(profile: profile)

// Save meal and update stats
let meal = Meal(
    id: UUID().uuidString,
    loggedAt: Date(),
    source: "manual",
    name: "Chicken & Rice",
    photoURL: nil,
    calories: 540,
    proteinG: 38,
    carbsG: 62,
    fatG: 12,
    smartSwap: nil
)
try await firebase.save(meal: meal, for: Date())
try await firebase.updateDayStats(for: Date(), adding: meal)

// Fetch today’s meals
let todaysMeals = try await firebase.fetchMeals(for: Date())
```

Notes:
- Requires an authenticated Firebase user for all methods except `deleteUserData(uid:)`.
- Firestore collections: `users/{uid}`, nested subcollections `meals`, `dayStats`.

---

## FoodRecognitionService

Protocol methods:

```swift
protocol FoodRecognitionService {
    func recognise(image: UIImage) async throws -> (name: String, calories: Int, protein: Int, carbs: Int, fat: Int)
}
```

Implementations:
- `FoodRecognitionServiceImpl`: Uses OpenAI Vision via `OpenAIService`.
- `FoodRecognitionServiceStub`: Returns mock values with a simulated delay.

Example:

```swift
let foodService: FoodRecognitionService = FoodRecognitionServiceImpl()
let result = try await foodService.recognise(image: image)
print(result.name, result.calories)
```

Fallback behavior: the default implementation logs errors and returns a stub tuple when recognition fails.

---

## OpenAIService

Method:

```swift
final class OpenAIService {
    func recognizeFood(from image: UIImage) async throws -> (name: String, calories: Int, protein: Int, carbs: Int, fat: Int)
}
```

Behavior:
- Converts image to base64 data URL
- Posts a chat completion request to `AppConfig.chatCompletionsEndpoint` using `AppConfig.gptVisionModel`
- Expects the assistant to reply with JSON matching `NutritionEstimate`
- Parses JSON and returns a typed tuple

Example:

```swift
let openAI = OpenAIService()
let tuple = try await openAI.recognizeFood(from: image)
print(tuple.name, tuple.calories)
```

Errors (`OpenAIError`):
- `.imageProcessingFailed`
- `.invalidResponse`
- `.apiError(Int)`
- `.noResponse`
- `.invalidJSON`

---

## AuthManager (Manager protocol)

```swift
protocol AuthManager {
    var currentUID: String? { get }
    var authStateStream: AsyncStream<User?> { get }
    func signInAnonymously() async throws
    func signOut() throws
}
```

Default manager: `FirebaseAuthManager` (wraps Firebase Auth state and exposes `currentUID` and `authStateStream`).

Example:

```swift
let manager = FirebaseAuthManager()
for await user in manager.authStateStream {
    print("Auth state changed: \(user?.uid ?? "none")")
}
try manager.signOut()
```