import Foundation
import SwiftUI

@MainActor
final class OnboardingViewModel: ObservableObject {
    
    // MARK: - Dependencies (set after onboarding completes)
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
    
    // HealthKit
    @Published var healthKitPermissionGranted = false
    private let healthKitService: HealthKitService
    
    // MARK: - Init
    init(healthKitService: HealthKitService = HealthKitServiceImpl()) {
        self.healthKitService = healthKitService
    }
    
    // MARK: - Setup Dependencies (No Firebase - offline only)
    func setupDependencies(router: AppRouter) {
        print("🎯 [OnboardingViewModel] setupDependencies - offline mode only")
        self.router = router
    }
    
    // MARK: - Navigation
    func next() {
        withAnimation {
            page = min(page + 1, 9)
        }
    }
    
    // MARK: - Save Current Page Data
    func saveCurrentPageData() {
        print("💾 [OnboardingViewModel] Saving data for page \(page)")
        
        // Save current state to UserDefaults for persistence
        let currentData: [String: Any] = [
            "page": page,
            "birthDate": birthDate,
            "sex": sex,
            "heightCm": heightCm,
            "weightKg": weightKg,
            "activityLevel": activityLevel,
            "target": target,
            "weeklyPaceKg": weeklyPaceKg,
            "dietType": dietType,
            "lang": lang,
            "lastUpdated": Date.now
        ]
        
        UserDefaults.standard.set(currentData, forKey: "onboardingProgress")
        print("✅ [OnboardingViewModel] Page \(page) data saved locally")
    }
    
    // MARK: - Finish Onboarding (Offline)
    func finish() async {
        print("🎯 [OnboardingViewModel] finish() called - saving locally only")
        
        // Save final onboarding data locally (will sync to Firebase later when user authenticates)
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
        print("✅ [OnboardingViewModel] Onboarding data saved locally (no network required)")
        
        // Navigate to auth for sign-up/log-in
        router?.to(.auth)
        print("✅ [OnboardingViewModel] Navigating to auth for sign-up/log-in")
    }
    
    // MARK: - HealthKit
    func requestHealthKitPermissions() async {
        do {
            let granted = try await healthKitService.requestPermissions()
            await MainActor.run {
                healthKitPermissionGranted = granted
                if granted {
                    print("✅ [OnboardingViewModel] HealthKit permissions granted")
                } else {
                    print("⚠️ [OnboardingViewModel] HealthKit permissions denied")
                }
            }
        } catch {
            print("❌ [OnboardingViewModel] HealthKit permission request failed: \(error)")
            await MainActor.run {
                healthKitPermissionGranted = false
            }
        }
    }
} 