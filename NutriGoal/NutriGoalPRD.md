# NutriGoal – Product Requirements Document (V2, July 2025)

---

## 1. Purpose & Vision

A **subscription‑only, iOS‑first fitness companion** that goes beyond calorie counting by:

* Removing meal‑logging guilt with **🔄 AI Smart Swap** (instant micro‑tweak suggestions).
* Delivering a **Weekly AI Report** that summarises progress and sets next‑week goals.
* Supporting multi‑language users (EN 🇺🇸, TR 🇹🇷, ES 🇪🇸, ZH 🇨🇳) from day one.

Launch focus: Turkey ➜ Europe ➜ North America ➜ Australia.

Pricing (RevenueCat): **\$20 / month** · **\$64 / year** · **8‑day free trial**. Apple Pay enabled via StoreKit2.

---

## 2. Core User Flows

1. **Onboarding (mandatory)** → collects profile → creates `/users/{uid}`.
2. **Home** (day dashboard) → meal log cards with Smart Swap.
3. **Progress** → weight, calories, BMR charts (7 / 30 / 90 d).
4. **Reports** → weekly AI summaries (phase 2).
5. **Settings** → subs, profile edit, language picker.

---

## 3. Onboarding Data & Calculations

### 3.1 Question set

| Step                                           | Field                        | Stored key |
| ---------------------------------------------- | ---------------------------- | ---------- |
| Birth date                                     | `birthDate`                  |            |
| Sex (M/F)                                      | `sex`                        |            |
| Height & units                                 | `height_cm` / `height_ft_in` |            |
| Weight & units                                 | `weight_kg` / `weight_lb`    |            |
| Activity (1‑2 / 3‑4 / 5‑6 days)                | `activityLevel`              |            |
| Fitness target (lose / maintain / gain muscle) | `target`                     |            |
| Weekly pace (kg/lb) & goal date                | `weeklyPaceKg`, `goalDate`   |            |
| Diet type (vegan / keto / etc.)                | `dietType`                   |            |
| Apple Health permissions                       | stored in Keychain flag      |            |
| Language (EN/TR/ES/ZH)                         | `lang`                       |            |

### 3.2 Daily Calorie & Macro Engine

1. **Basal Metabolic Rate (Mifflin‑St Jeor)**
   `BMR = 10 × weightKg + 6.25 × heightCm – 5 × age + s` where `s = +5 (male)` / `‑161 (female)`
2. **TDEE** = BMR × activity factor (1.2 / 1.375 / 1.55).
3. **Calorie target**

   * weight‑loss ⇒ `‑(weeklyPaceKg × 7700) / 7` kcal def  (min 1200 kcal)
   * gain‑muscle ⇒ surplus `+300`.
4. **Macro ranges**

   * Protein = `1.6‑2.2 g × weightKg`
   * Fat = `0.8‑1.0 g × weightKg`
   * Carbs = calories‑derived remainder.
5. **Hydration goal** = `35 ml × weightKg`.
6. **Sleep target** = 7‑9 h (advice text only).

All values stored nightly into `/dayStats/{date}`.

---

## 4. Firestore Schema (MVVM‑light‑friendly)

```
users/{uid}                        // profile doc
└─ meals/{mealId}                  // per meal
└─ dayStats/{yyyy-MM-dd}           // aggregates + score
└─ weightLogs/{timestamp}          // weigh‑ins
└─ weeklyReports/{yyyy-WW}         // phase 2 AI summary
```

(Field definitions identical to previous schema.)

Security rule skeleton:

```firestore
match /users/{userId}/{doc=**} {
  allow read, write: if request.auth.uid == userId;
}
```

---

## 5. Architecture Roadmap

### 5.1 **Phase 1 – MVVM‑light** (current repo state)

```
Features/
  Home/ MealLogging/ Progress/ Reports/ Settings/
Shared/
  Models/ ViewModels/ Managers/ Services/ Utilities/
```

* ViewModels call `FirebaseService`, `OpenAIService`, `HealthKitService` directly.
* Dependency Injection via Resolver container (already in repo).

### 5.2 **Phase 2 – Gradual Clean MVVM** (>100 k MAU)

1. Create `Domain/` Swift Package → Entities & UseCases.
2. Extract ViewModel logic into UseCases.
3. Convert Services into Repository implementations under `Data/`.
4. Wire DI (Resolver) to expose `MealRepository`, `SmartSwapUseCase`, etc. No breaking changes to Firestore paths.

---

## 6. Unique AI Features

| Feature                     | Description                                                                                     | GPT prompt footprint                   |
| --------------------------- | ----------------------------------------------------------------------------------------------- | -------------------------------------- |
| **Smart Swap (v1)**         | Suggest ≤2 realistic tweaks to any meal so macros fit remaining range.                          |  <120 tokens ≈ \$0.002 per call.       |
| **Weekly AI Report (v1.5)** | Sunday midnight Cloud Function summarises week, scores habit pillars, suggests next‑week focus. |  Stored in `/weeklyReports/{yyyy‑WW}`. |

Caching: key `mealHash|remainP|remainC|remainF|lang` in local dictionary & Firestore sub‑collection.

---

## 7. Monetisation

* **Subscription product** ID: `nutrigoal.pro`
* Price tier: *\$19.99/mo*, *\$63.99/yr* (tier mapping auto‑localised).
* **8‑day free trial** (Apple, RevenueCat).
  RevenueCat entitlements: `pro_monthly`, `pro_annual`.
* Paywall displays `package.localizedPriceString` for locale.

---

## 8. Localisation Plan (EN, TR, ES, ZH‑Hans)

1. `Localizable.strings` via SwiftGen; English key names.
2. Language picker writes `lang` in `/users/{uid}` and UserDefaults.
3. GPT prompts include `Language: xx` for Smart Swap & Reports.
4. Date, decimal formatting via `Locale.current`.
5. App Store screenshots per language.

---

## 9. Coding Style & Cursor Tips

* **Feature folders** keep View, ViewModel, Manager together → minimal file‑hopping.
* Always create a **protocol** first (`MealLoggingManager`) then let Cursor implement.
* Use \`\` headers; run SwiftLint.
* For every Firestore write, add `Task { await analytics.log(...) }` for insight.
* Cursor commands:

  * `c scaffold feature {Name}`  – fastest way to create boilerplate.
  * Highlight service call → **“Extract to UseCase”** when refactoring to Clean.
  * “Create XCTests for *Class*” – auto‑mocks protocols.

---

## 10. Phased Delivery Timeline

| Sprint | Deliverable                                                             |
| ------ | ----------------------------------------------------------------------- |
| 1      | Onboarding flow → `/users` doc write; calorie/macro engine unit‑tested. |
| 2      | MealLogging (photo, gallery, barcode) + OpenAI macro parse.             |
| 3      | Smart Swap UseCase + cache; Home day dashboard.                         |
| 4      | Progress graphs; weight & calorie aggregation.                          |
| 5      | RevenueCat paywall, localisation files, crash + perf SDK.               |
| 6      | Internal TestFlight beta → iterate.                                     |
| 7      | Launch (Turkey + English markets) — gather traction.                    |
| 8      | Add Weekly AI Report & Reports tab; Australia/US marketing.             |

---

**End of document**
