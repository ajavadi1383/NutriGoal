# Models

Swift data structures used across the app.

## Meal

```swift
struct Meal: Codable, Identifiable {
    var id: String?
    let loggedAt: Date
    let source: String // "photo" or "manual"
    let name: String
    let photoURL: URL?
    let calories: Int
    let proteinG: Int
    let carbsG: Int
    let fatG: Int
    let smartSwap: SmartSwap?
}
```

Example:

```swift
let meal = Meal(
  id: UUID().uuidString,
  loggedAt: Date(),
  source: "manual",
  name: "Greek Yogurt",
  photoURL: nil,
  calories: 180,
  proteinG: 18, carbsG: 12, fatG: 4,
  smartSwap: nil
)
```

---

## DayStats

```swift
struct DayStats: Codable, Identifiable {
    var id: String?
    let date: String // yyyy-MM-dd
    let caloriesTotal: Int
    let proteinTotal: Int
    let carbsTotal: Int
    let fatTotal: Int
    let steps: Int
    let workoutMin: Int
    let waterMl: Int
    let sleepMin: Int
    let bedtime: String
    let score: Double
}
```

---

## SmartSwap

```swift
struct SmartSwap: Codable {
    let suggestion: String
    let newCalories: Int
    let newProteinG: Int
    let newCarbsG: Int
    let newFatG: Int
}
```

---

## UserProfile

```swift
struct UserProfile: Codable, Identifiable {
    var id: String?
    let email: String
    let birthDate: Date
    let sex: String // "male" or "female"
    let heightCm: Int
    let weightKg: Double
    let activityLevel: String // "1-2", "3-4", "5-6"
    let target: String // "lose", "maintain", "gain"
    let weeklyPaceKg: Double
    let goalDate: Date
    let dietType: String // e.g., "none", "vegetarian"
    let lang: String // e.g., "en", "tr", "es"
    let createdAt: Date
}
```

---

## WeeklyReport

```swift
struct WeeklyReport: Codable, Identifiable {
    var id: String?
    let week: String
    let summaryText: String
    let avgScore: Double
    let suggestions: String
}
```