# NutriGoal iOS App

NutriGoal is an AI-powered nutrition and lifestyle tracker designed to help users achieve their health goals through intelligent coaching, daily journaling, and holistic lifestyle scoring.

## 🚀 Features

- **AI-Generated Daily Journals**: Personalized daily insights and reflections
- **Chat-based AI Coach**: Real-time motivation and habit coaching  
- **Lifestyle Scoring**: Holistic 0-10 scoring based on nutrition, activity, sleep, and hydration
- **Range-based Goals**: Flexible calorie and macro targets instead of rigid limits
- **HealthKit Integration**: Automatic tracking of steps, sleep, and workouts
- **Food Recognition**: AI-powered photo recognition and barcode scanning

## 🏗️ Architecture

The app follows **MVVM Clean Architecture** principles:

```
NutriGoal/
├── Presentation/          # UI Layer (SwiftUI Views & ViewModels)
│   ├── Views/
│   ├── ViewModels/
│   └── UIModels/
├── Domain/               # Business Logic Layer
│   ├── Entities/         # Core data models
│   ├── UseCases/         # Business logic implementations
│   └── Interfaces/       # Repository protocols
├── Data/                 # Data Access Layer
│   ├── Services/         # External API services
│   ├── Repositories/     # Data repository implementations
│   └── Mappers/          # Data transformation
└── Core/                 # Shared utilities
    ├── Configuration/    # App configuration
    ├── DependencyInjection/
    ├── Extensions/
    └── Utilities/
```

## 🛠️ Tech Stack

- **iOS**: iOS 17+ (iPhone only)
- **UI Framework**: SwiftUI
- **Architecture**: MVVM Clean Architecture
- **Reactive Programming**: Combine
- **Backend**: Firebase (Auth, Firestore, Cloud Functions)
- **AI Services**: OpenAI GPT-4o
- **Subscriptions**: RevenueCat
- **Health Data**: HealthKit
- **Nutrition APIs**: Open Food Facts, USDA API

## 💰 Monetization

- **Subscription Model**: $9.99/month or $59.99/year
- **No freemium tier**: Premium experience from day one

## 🔧 Current Status

**Phase 1 - Foundation Complete** ✅
- [x] Project structure setup
- [x] Clean architecture implementation
- [x] Core domain entities (User, Meal, JournalEntry, LifestyleScore)
- [x] Repository interfaces and use cases
- [x] Dependency injection container
- [x] Basic UI foundation with welcome screen and dashboard
- [x] Mock implementations for development

## 🚧 Next Steps

**Phase 2 - Authentication & Onboarding**
- [ ] Firebase Authentication integration
- [ ] User onboarding flow
- [ ] Profile setup and goal calculation

**Phase 3 - Core Features**
- [ ] Food logging system
- [ ] HealthKit integration
- [ ] AI journaling implementation
- [ ] Lifestyle score calculation

**Phase 4 - AI Features**
- [ ] OpenAI integration
- [ ] Chat-based AI coach
- [ ] Food photo recognition

## 🏃‍♂️ Getting Started

1. Clone the repository
2. Open `NutriGoal.xcodeproj` in Xcode
3. Build and run on iOS 17+ simulator or device

The app currently runs with mock data for development purposes. Real integrations will be added in subsequent phases.

## 📱 App Flow

1. **Welcome Screen**: Feature overview and call-to-action
2. **Onboarding**: Goal setting and profile creation (Phase 2)
3. **Dashboard**: Daily score and quick actions
4. **Food Logging**: Multiple input methods (Phase 3)
5. **AI Journal**: Generated daily insights (Phase 3)
6. **AI Coach**: Chat-based motivation (Phase 4)

## 🔐 Security & Privacy

- User data encrypted and stored securely
- HealthKit data access with explicit permissions
- Firebase security rules for data protection
- GDPR and privacy-compliant design

---

**Built with ❤️ for healthier living** 