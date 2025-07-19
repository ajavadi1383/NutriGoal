//
//  NutriGoalApp.swift
//  NutriGoal
//
//  Created by Amirali Javadi on 6/7/25.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

@main
struct NutriGoalApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - App Delegate for Google Sign-In
class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        print("🚀 [AppDelegate] App finished launching")
        return true
    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        print("🔗 [AppDelegate] Handling URL: \(url)")
        
        // Handle Google Sign-In callback
        if GIDSignIn.sharedInstance.handle(url) {
            print("✅ [AppDelegate] Google Sign-In handled URL")
            return true
        }
        
        return false
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
                    .font(NGFont.bodyM)
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
