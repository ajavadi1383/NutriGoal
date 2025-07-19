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
    @StateObject private var authManager = FirebaseAuthManager()
    @State private var showOnboarding = false
    
    var body: some View {
        Group {
            if UserDefaults.standard.bool(forKey: "onboarded") == false {
                HeroView()
            } else if authManager.currentUID != nil {
                if showOnboarding {
                    OnboardingView(authManager: authManager) {
                        showOnboarding = false
                        // TODO: Set onboarded flag after onboarding completes
                        UserDefaults.standard.set(true, forKey: "onboarded")
                    }
                } else {
                    // TODO: Main app view after onboarding
                    Text("Welcome to NutriGoal!")
                        .font(.largeTitle)
                }
            } else {
                HeroView()
            }
        }
        .task {
            for await user in authManager.authStateStream {
                if user != nil && !showOnboarding {
                    showOnboarding = true
                }
            }
        }
    }
}
