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
            if authManager.currentUID != nil {
                if showOnboarding {
                    OnboardingView(authManager: authManager) {
                        showOnboarding = false
                    }
                } else {
                    // TODO: Main app view after onboarding
                    Text("Welcome to NutriGoal!")
                        .font(.largeTitle)
                }
            } else {
                // TODO: Landing/welcome screen
                Button("Get Started") {
                    Task {
                        do {
                            try await authManager.signInAnonymously()
                            showOnboarding = true
                        } catch {
                            print("❌ [\(#function)] \(error.localizedDescription)")
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
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
