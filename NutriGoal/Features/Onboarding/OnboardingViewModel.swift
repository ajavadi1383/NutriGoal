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
        do {
            guard let uid = authManager?.currentUID else {
                print("❌ No authenticated user")
                return
            }
            
            // Build UserProfile
            let profile = UserProfile(
                id: uid,
                email: "anonymous@nutrigoal.app", // TODO: Get actual email when auth is expanded
                birthDate: birthDate,
                sex: sex,
                heightCm: heightCm,
                weightKg: weightKg,
                activityLevel: activityLevel,
                target: target,
                weeklyPaceKg: weeklyPaceKg,
                goalDate: Calendar.current.date(byAdding: .month, value: 3, to: Date.now) ?? Date.now,
                dietType: dietType,
                lang: lang,
                createdAt: Date.now
            )
            
            // Save to Firebase
            try await firebaseService?.save(profile: profile)
            
            // Mark as onboarded
            UserDefaults.standard.set(true, forKey: "onboarded")
            
            // Navigate to home
            router?.to(.home)
            
        } catch {
            print("❌ [\(#function)] \(error.localizedDescription)")
        }
    }
} 