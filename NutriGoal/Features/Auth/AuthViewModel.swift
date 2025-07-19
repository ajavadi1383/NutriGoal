import Foundation
import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let authService: FirebaseAuthService
    private let router: AppRouter
    
    // MARK: - Published Properties
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    
    // MARK: - Computed Properties
    var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && email.contains("@")
    }
    
    // MARK: - Initialization
    init(router: AppRouter) {
        // TODO: Inject via Resolver
        self.authService = FirebaseAuthServiceImpl()
        self.router = router
    }
    
    // MARK: - Email Authentication
    func signInTapped() async {
        print("🔐 [AuthViewModel] Sign in tapped")
        isLoading = true
        
        do {
            let result = try await authService.signIn(email: email, password: password)
            print("✅ [AuthViewModel] Sign in successful: \(result.user.uid)")
            await syncOnboardingDataIfNeeded()
            router.to(.home)
        } catch {
            print("❌ [AuthViewModel] Sign in failed: \(error)")
            // TODO: Show error to user
        }
        
        isLoading = false
    }
    
    func signUpTapped() async {
        print("🔐 [AuthViewModel] Sign up tapped")
        isLoading = true
        
        do {
            let result = try await authService.createUser(email: email, password: password)
            print("✅ [AuthViewModel] Sign up successful: \(result.user.uid)")
            await syncOnboardingDataIfNeeded()
            router.to(.home)
        } catch {
            print("❌ [AuthViewModel] Sign up failed: \(error)")
            // TODO: Show error to user
        }
        
        isLoading = false
    }
    
    // MARK: - Apple Authentication
    func appleTapped() async {
        print("🍎 [AuthViewModel] Apple sign-in tapped")
        isLoading = true
        
        do {
            let result = try await authService.signInWithApple()
            print("✅ [AuthViewModel] Apple sign-in successful: \(result.user.uid)")
            await syncOnboardingDataIfNeeded()
            router.to(.home)
        } catch {
            print("❌ [AuthViewModel] Apple sign-in failed: \(error)")
            // TODO: Show error to user
        }
        
        isLoading = false
    }
    
    // MARK: - Skip Authentication
    func skipTapped() {
        print("⏭️ [AuthViewModel] Skip tapped - going to home")
        router.to(.home)
    }
    
    // MARK: - Helper Methods
    private func syncOnboardingDataIfNeeded() async {
        print("🔄 [AuthViewModel] Syncing onboarding data to Firebase")
        
        // Get locally saved onboarding data
        guard let onboardingData = UserDefaults.standard.object(forKey: "onboardingData") as? [String: Any] else {
            print("ℹ️ [AuthViewModel] No onboarding data found to sync")
            return
        }
        
        // TODO: Save to Firestore using FirebaseService
        print("📝 [AuthViewModel] Onboarding data ready for Firestore sync: \(onboardingData.keys)")
        
        // Clear local data after sync
        UserDefaults.standard.removeObject(forKey: "onboardingData")
        UserDefaults.standard.removeObject(forKey: "onboardingProgress")
        print("✅ [AuthViewModel] Local onboarding data cleared after sync")
    }
} 