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
    @Published var isSignUpMode = true
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    // MARK: - Computed Properties
    var isFormValid: Bool {
        !email.isEmpty && password.count >= 6
    }
    
    // MARK: - Initialization
    init(authService: FirebaseAuthService, router: AppRouter) {
        self.authService = authService
        self.router = router
    }
    
    // MARK: - Actions
    func submit() async {
        guard isFormValid else {
            errorMessage = "Please enter a valid email and password (6+ characters)"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            if isSignUpMode {
                print("📝 [AuthViewModel] Creating new user account...")
                try await authService.createUser(email: email, password: password)
                print("✅ [AuthViewModel] Account created successfully")
            } else {
                print("🔐 [AuthViewModel] Signing in existing user...")
                try await authService.signIn(email: email, password: password)
                print("✅ [AuthViewModel] Sign in successful")
            }
            
            // Navigate to onboarding on success
            print("🚀 [AuthViewModel] Navigating to onboarding...")
            router.to(.onboarding)
            
        } catch {
            print("❌ [AuthViewModel] Authentication failed: \(error.localizedDescription)")
            errorMessage = getErrorMessage(from: error)
        }
        
        isLoading = false
    }
    
    func toggleMode() {
        isSignUpMode.toggle()
        errorMessage = nil
    }
    
    // MARK: - Helper Methods
    private func getErrorMessage(from error: Error) -> String {
        // Convert Firebase auth errors to user-friendly messages
        let errorMessage = error.localizedDescription
        
        if errorMessage.contains("email") {
            return "Please enter a valid email address"
        } else if errorMessage.contains("password") {
            return "Password must be at least 6 characters"
        } else if errorMessage.contains("user-not-found") {
            return "No account found with this email"
        } else if errorMessage.contains("wrong-password") {
            return "Incorrect password"
        } else if errorMessage.contains("email-already-in-use") {
            return "An account with this email already exists"
        } else {
            return "Authentication failed. Please try again."
        }
    }
} 