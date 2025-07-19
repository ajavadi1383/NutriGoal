//
//  NutriGoalApp.swift
//  NutriGoal
//
//  Created by Amirali Javadi on 6/7/25.
//

import SwiftUI
import FirebaseCore

@main
struct NutriGoalApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @StateObject private var router = AppRouter()
    @StateObject private var authManager = FirebaseAuthManager()
    
    var body: some View {
        Group {
            switch router.route {
            case .hero:
                HeroView(router: router)
            case .auth:
                AuthView(router: router)
            case .onboarding:
                OnboardingView()
                    .environmentObject(router)
            case .home:
                HomeView(router: router)
            }
        }
        .onAppear {
            setupInitialRoute()
        }
    }
    
    private func setupInitialRoute() {
        let isOnboarded = UserDefaults.standard.bool(forKey: "onboarded")
        print("🚀 [NutriGoalApp] App starting...")
        print("📱 [NutriGoalApp] Onboarded status: \(isOnboarded)")
        
        // FOR TESTING: Reset onboarding to always start fresh
        UserDefaults.standard.set(false, forKey: "onboarded")
        print("🔄 [NutriGoalApp] Reset onboarding for testing")
        
        // Always start with Hero for now
        router.to(.hero)
        print("✅ [NutriGoalApp] Starting with Hero screen")
    }
}

struct HomeView: View {
    let router: AppRouter
    
    var body: some View {
        HeroBaseView {
            VStack(spacing: NGSize.spacing * 2) {
                Spacer()
                
                Text("Welcome to NutriGoal!")
                    .font(NGFont.titleXL)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Your health journey starts here")
                    .font(NGFont.bodyM)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                // User Status
                VStack(spacing: NGSize.spacing / 2) {
                    if let email = getCurrentUserEmail() {
                        Text("Signed in as:")
                            .font(NGFont.bodyS)
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text(email)
                            .font(NGFont.bodyM)
                            .foregroundColor(.white)
                            .fontWeight(.medium)
                    } else {
                        Text("Not signed in")
                            .font(NGFont.bodyM)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: NGSize.spacing) {
                    PrimaryButton(title: "Continue to App") {
                        print("🏠 HomeView: Continue to App tapped")
                        router.to(.onboarding) // Navigate to main app flow
                    }
                    
                    if getCurrentUserEmail() != nil {
                        PrimaryButton(title: "Sign Out") {
                            signOut(router: router)
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    } else {
                        PrimaryButton(title: "Sign In") {
                            router.to(.auth)
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    private func getCurrentUserEmail() -> String? {
        // TODO: Get from Firebase Auth
        return nil // For now, will be implemented with Firebase Auth integration
    }
    
    private func signOut(router: AppRouter) {
        print("🔓 HomeView: Sign out tapped")
        // TODO: Implement sign out with Firebase Auth
        router.to(.hero)
    }
}
