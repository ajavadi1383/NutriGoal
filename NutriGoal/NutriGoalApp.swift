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
            case .onboarding:
                OnboardingView()
                    .environmentObject(router)
            case .home:
                HomeView()
            }
        }
        .task {
            // Check onboarding status and set initial route
            if UserDefaults.standard.bool(forKey: "onboarded") {
                router.to(.home)
            } else {
                router.to(.hero)
            }
        }
    }
}

struct HomeView: View {
    var body: some View {
        Text("Welcome to NutriGoal!")
            .font(.largeTitle)
    }
}
