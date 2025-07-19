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
                HomeView()
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
    var body: some View {
        HeroBaseView {
            VStack(spacing: NGSize.spacing * 2) {
                Spacer()
                
                Text("Welcome to NutriGoal!")
                    .font(NGFont.titleXL)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Your health journey starts here")
                    .font(NGFont.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                PrimaryButton(title: "Continue") {
                    // TODO: Navigate to main app
                    print("🏠 Home: Continue tapped")
                }
            }
            .padding()
        }
    }
}
