# Components

Reusable SwiftUI components and their public interfaces.

## PrimaryButton

```swift
struct PrimaryButton: View {
    init(title: String, action: @escaping () -> Void)
}
```

Usage:

```swift
PrimaryButton(title: "Get Started") {
    // handle tap
}
```

Notes: Uses `NGColor.primary`, fills width, 48pt height, rounded corners.

---

## CalorieRing

```swift
struct CalorieRing: View {
    init(consumed: Int, min: Int, max: Int)
}
```

Usage:

```swift
CalorieRing(consumed: 1800, min: 1500, max: 2000)
```

Behavior: Displays progress toward max with color indicating below/min/over range.

---

## ScoreRing

```swift
struct ScoreRing: View {
    init(score: Double) // clamps to 0...10
}
```

Usage:

```swift
ScoreRing(score: 7.2)
```

Behavior: Shows emoji and a colored ring based on the score.

---

## MacroBar

```swift
struct MacroBar: View {
    init(name: String, progress: Double, current: Int, min: Int, max: Int)
}
```

Usage:

```swift
MacroBar(name: "Protein", progress: 0.8, current: 120, min: 100, max: 150)
```

Behavior: Horizontal bar with color indicating below/over/in range.

---

## LanguageFlagChip

```swift
struct LanguageFlagChip: View {
    init(code: String)
}
```

Usage:

```swift
HStack { LanguageFlagChip(code: "en"); LanguageFlagChip(code: "tr") }
```

Behavior: Displays an SF Symbol flag and uppercase language code.

---

## HeroBaseView and HeroPageView

```swift
struct HeroBaseView<Content: View>: View {
    init(@ViewBuilder content: () -> Content)
}

struct HeroPageView<Content: View>: View {
    init(title: String, @ViewBuilder content: () -> Content)
}
```

Usage:

```swift
HeroBaseView {
    HeroPageView(title: "Welcome") {
        Text("Content")
    }
}
```

Provides the gradient background and standardized spacing/typography.

---

## Styles and Tokens

- `NGColor`: `primary`, `secondary`, `gray1-6`
- `NGFont`: `titleXL`, `bodyM`
- `NGSize`: `corner`, `spacing`

Additional styles in feature views:
- `HeroTextFieldStyle`
- `SecondaryButtonStyle`