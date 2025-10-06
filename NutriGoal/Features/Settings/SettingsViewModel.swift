import Foundation
import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let authService: FirebaseAuthService
    private let firebaseService: FirebaseService
    private let healthKitService: HealthKitService
    
    // MARK: - Published Properties
    @Published var healthKitConnected = false
    @Published var dietType = "balanced"
    @Published var languageName = "English"
    @Published var showDeleteAlert = false
    @Published var isDeleting = false
    
    // MARK: - Init
    init(
        authService: FirebaseAuthService? = nil,
        firebaseService: FirebaseService? = nil,
        healthKitService: HealthKitService? = nil
    ) {
        self.authService = authService ?? FirebaseAuthServiceImpl()
        self.firebaseService = firebaseService ?? FirebaseServiceImpl()
        self.healthKitService = healthKitService ?? HealthKitServiceImpl()
        loadSettings()
    }
    
    // MARK: - Load Settings
    private func loadSettings() {
        // Load from UserDefaults/Firestore
        if let onboardingData = UserDefaults.standard.object(forKey: "onboardingData") as? [String: Any] {
            dietType = onboardingData["dietType"] as? String ?? "balanced"
            
            if let lang = onboardingData["lang"] as? String {
                languageName = languageDisplayName(lang)
            }
        }
    }
    
    // MARK: - Actions
    func editProfileTapped() {
        print("⚙️ Edit Profile tapped")
        // TODO: Navigate to profile edit
    }
    
    func goalsTapped() {
        print("⚙️ Goals tapped")
        // TODO: Navigate to goals edit
    }
    
    func dietPreferencesTapped() {
        print("⚙️ Diet preferences tapped")
        // TODO: Show diet picker
    }
    
    func toggleHealthKit() async {
        do {
            let granted = try await healthKitService.requestPermissions()
            healthKitConnected = granted
            print("✅ HealthKit: \(granted ? "Connected" : "Denied")")
        } catch {
            print("❌ HealthKit toggle failed: \(error)")
        }
    }
    
    func exportDataTapped() {
        print("⚙️ Export data tapped")
        // TODO: Generate CSV/JSON export
    }
    
    func notificationsTapped() {
        print("⚙️ Notifications tapped")
        // TODO: Navigate to notification settings
    }
    
    func languageTapped() {
        print("⚙️ Language tapped")
        // TODO: Show language picker
    }
    
    func themeTapped() {
        print("⚙️ Theme tapped")
        // TODO: Theme customization (future)
    }
    
    func subscriptionTapped() {
        print("⚙️ Subscription tapped")
        // TODO: Navigate to RevenueCat subscription management
    }
    
    func restorePurchasesTapped() {
        print("⚙️ Restore purchases tapped")
        // TODO: Call RevenueCat restore
    }
    
    func signOutTapped(router: AppRouter) {
        do {
            try authService.signOut()
            router.to(.hero)
            print("✅ Signed out successfully")
        } catch {
            print("❌ Sign out failed: \(error)")
        }
    }
    
    func deleteAccountTapped() {
        showDeleteAlert = true
    }
    
    func confirmDeleteAccount(router: AppRouter) async {
        guard let uid = authService.getCurrentUser()?.uid else { return }
        
        isDeleting = true
        
        do {
            // Delete Firestore data
            try await firebaseService.deleteUserData(uid: uid)
            
            // Delete auth user
            try await authService.deleteCurrentUser()
            
            // Navigate to hero
            router.to(.hero)
            
            print("✅ Account deleted successfully")
        } catch {
            print("❌ Delete account failed: \(error)")
        }
        
        isDeleting = false
    }
    
    // MARK: - Helpers
    private func languageDisplayName(_ code: String) -> String {
        switch code {
        case "en": return "English"
        case "tr": return "Türkçe"
        case "es": return "Español"
        case "zh": return "中文"
        default: return "English"
        }
    }
}

