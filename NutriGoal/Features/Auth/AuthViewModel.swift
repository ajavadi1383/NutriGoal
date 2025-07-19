import Foundation
import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let authService: FirebaseAuthService
    private let firebaseService: FirebaseService
    private let router: AppRouter
    
    // MARK: - Published Properties
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var loadingMessage = ""
    
    // MARK: - Computed Properties
    var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && email.contains("@") && password.count >= 6
    }
    
    // MARK: - Initialization
    init(router: AppRouter) {
        // TODO: Inject via Resolver
        self.authService = FirebaseAuthServiceImpl()
        self.firebaseService = FirebaseServiceImpl()
        self.router = router
    }
    
    // MARK: - Email Authentication
    func signUpTapped() async {
        print("🔐 [AuthViewModel] Sign up tapped")
        isLoading = true
        loadingMessage = "Creating your account..."
        
        do {
            // Create Firebase Auth user
            let result = try await authService.createUser(email: email, password: password)
            print("✅ [AuthViewModel] Sign up successful: \(result.user.uid)")
            
            loadingMessage = "Setting up your profile..."
            
            // Create user profile in Firestore
            await createUserProfile(for: result.user.uid, email: email)
            
            // Sync any existing onboarding data
            await syncOnboardingDataIfNeeded()
            
            loadingMessage = "Welcome aboard!"
            
            // Small delay to show success message
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            router.to(.home)
            
        } catch {
            print("❌ [AuthViewModel] Sign up failed: \(error)")
            showError("Failed to create account: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func signInTapped() async {
        print("🔐 [AuthViewModel] Sign in tapped")
        isLoading = true
        loadingMessage = "Signing you in..."
        
        do {
            let result = try await authService.signIn(email: email, password: password)
            print("✅ [AuthViewModel] Sign in successful: \(result.user.uid)")
            
            loadingMessage = "Loading your data..."
            
            // Sync any existing onboarding data
            await syncOnboardingDataIfNeeded()
            
            loadingMessage = "Welcome back!"
            
            // Small delay to show success message
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            router.to(.home)
            
        } catch {
            print("❌ [AuthViewModel] Sign in failed: \(error)")
            showError("Failed to sign in: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    // MARK: - Skip Authentication
    func skipTapped() {
        print("⏭️ [AuthViewModel] Skip tapped - going to home")
        router.to(.home)
    }
    
    // MARK: - Helper Methods
    private func createUserProfile(for uid: String, email: String) async {
        print("👤 [AuthViewModel] Creating user profile in Firestore")
        
        // Get onboarding data if available
        let onboardingData = UserDefaults.standard.object(forKey: "onboardingData") as? [String: Any] ?? [:]
        
        // Create UserProfile with default or onboarding data
        let profile = UserProfile(
            id: uid,
            email: email,
            birthDate: onboardingData["birthDate"] as? Date ?? Date(),
            sex: onboardingData["sex"] as? String ?? "M",
            heightCm: onboardingData["heightCm"] as? Int ?? 175,
            weightKg: onboardingData["weightKg"] as? Double ?? 70.0,
            activityLevel: onboardingData["activityLevel"] as? String ?? "moderate",
            target: onboardingData["target"] as? String ?? "maintain",
            weeklyPaceKg: onboardingData["weeklyPaceKg"] as? Double ?? 0.5,
            goalDate: onboardingData["goalDate"] as? Date ?? Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date(),
            dietType: onboardingData["dietType"] as? String ?? "balanced",
            lang: onboardingData["lang"] as? String ?? "en",
            createdAt: Date()
        )
        
        do {
            try await firebaseService.save(profile: profile)
            print("✅ [AuthViewModel] User profile saved to Firestore")
        } catch {
            print("❌ [AuthViewModel] Failed to save user profile: \(error)")
            // Don't show error to user, continue with auth flow
        }
    }
    
    private func syncOnboardingDataIfNeeded() async {
        print("🔄 [AuthViewModel] Checking for onboarding data to sync")
        
        // Get locally saved onboarding data
        guard let onboardingData = UserDefaults.standard.object(forKey: "onboardingData") as? [String: Any] else {
            print("ℹ️ [AuthViewModel] No onboarding data found to sync")
            return
        }
        
        print("📝 [AuthViewModel] Found onboarding data to sync: \(onboardingData.keys)")
        
        // Data already synced in createUserProfile, so just clear local storage
        UserDefaults.standard.removeObject(forKey: "onboardingData")
        UserDefaults.standard.removeObject(forKey: "onboardingProgress")
        print("✅ [AuthViewModel] Local onboarding data cleared after sync")
    }
    
    private func showError(_ message: String) {
        alertMessage = message
        showAlert = true
    }
} 