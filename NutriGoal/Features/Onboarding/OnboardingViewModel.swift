import Foundation
import SwiftUI

@MainActor
final class OnboardingViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private var authManager: AuthManager?
    private var firebaseService: FirebaseService?
    private var router: AppRouter?
    
    // MARK: - Published Properties
    @Published var page = 0
    @Published var birthDate = Date.now.addingTimeInterval(-25 * 365 * 24 * 60 * 60) // Default: 25 years old
    @Published var sex = ""
    @Published var heightCm = 170
    @Published var weightKg = 70.0
    @Published var activityLevel = ""
    @Published var target = ""
    @Published var weeklyPaceKg = 0.5
    @Published var dietType = ""
    @Published var lang = ""
    
    // MARK: - Setup Dependencies
    func setupDependencies(router: AppRouter) {
        // TODO: Inject via Resolver
        self.authManager = FirebaseAuthManager()
        self.firebaseService = FirebaseServiceImpl()
        self.router = router
    }
    
    // MARK: - Navigation
    func next() {
        withAnimation {
            page = min(page + 1, 8)
        }
    }
    
    // MARK: - Finish Onboarding
    func finish() async {
        print("🎯 [OnboardingViewModel] finish() called")
        
        // Save onboarding data locally (will sync to Firebase later when user authenticates)
        let onboardingData: [String: Any] = [
            "birthDate": birthDate,
            "sex": sex,
            "heightCm": heightCm,
            "weightKg": weightKg,
            "activityLevel": activityLevel,
            "target": target,
            "weeklyPaceKg": weeklyPaceKg,
            "dietType": dietType,
            "lang": lang,
            "createdAt": Date.now
        ]
        
        // Save to UserDefaults for now
        UserDefaults.standard.set(onboardingData, forKey: "onboardingData")
        
        // Mark as onboarded
        UserDefaults.standard.set(true, forKey: "onboarded")
        print("✅ [OnboardingViewModel] Onboarding data saved locally")
        
        // Navigate to home
        router?.to(.home)
        print("✅ [OnboardingViewModel] Navigating to home")
    }
} 