//
//  NutriGoalApp.swift
//  NutriGoal
//
//  Created by Amirali Javadi on 6/7/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

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
            case .mainApp:
                MainAppView(router: router)
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
                            .font(NGFont.bodyM)
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
                        router.to(.mainApp) // Navigate to main app dashboard
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
        return Auth.auth().currentUser?.email
    }
    
    private func signOut(router: AppRouter) {
        print("🔓 HomeView: Sign out tapped")
        do {
            try Auth.auth().signOut()
            router.to(.hero)
        } catch {
            print("❌ Sign out failed: \(error)")
        }
    }
}

// MARK: - Main App View with Tab Navigation
struct MainAppView: View {
    let router: AppRouter
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            MealLoggingView()
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("Meals")
                }
            
            ProgressView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Progress")
                }
            
            SettingsView(router: router)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .accentColor(NGColor.primary)
    }
}

// MARK: - Dashboard View (Main Home)
struct DashboardView: View {
    var body: some View {
        HeroBaseView {
            ScrollView {
                VStack(spacing: NGSize.spacing * 2) {
                    // Header
                    VStack(spacing: NGSize.spacing / 2) {
                        Text("Today's Progress")
                            .font(NGFont.titleL)
                            .foregroundColor(.white)
                        
                        Text(Date().formatted(date: .abbreviated, time: .omitted))
                            .font(NGFont.bodyM)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top)
                    
                    // Daily Stats Cards
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: NGSize.spacing) {
                        DashboardCard(title: "Calories", value: "1,247", target: "2,100", icon: "flame.fill")
                        DashboardCard(title: "Protein", value: "45g", target: "140g", icon: "leaf.fill")
                        DashboardCard(title: "Water", value: "1.2L", target: "2.5L", icon: "drop.fill")
                        DashboardCard(title: "Steps", value: "8,234", target: "10,000", icon: "figure.walk")
                    }
                    
                    // Today's Meals
                    VStack(alignment: .leading, spacing: NGSize.spacing) {
                        HStack {
                            Text("Today's Meals")
                                .font(NGFont.titleM)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button("Add Meal") {
                                // TODO: Add meal action
                            }
                            .foregroundColor(NGColor.primary)
                            .font(NGFont.bodyM)
                        }
                        
                        VStack(spacing: NGSize.spacing / 2) {
                            MealCard(mealType: "Breakfast", calories: 420, time: "8:30 AM")
                            MealCard(mealType: "Lunch", calories: 650, time: "12:45 PM")
                            MealCard(mealType: "Snack", calories: 177, time: "3:20 PM")
                            
                            // Add Dinner placeholder
                            AddMealCard(mealType: "Dinner")
                        }
                    }
                    
                    Spacer(minLength: 100) // Extra space for tab bar
                }
                .padding()
            }
        }
    }
}

// MARK: - Dashboard Card Component
struct DashboardCard: View {
    let title: String
    let value: String
    let target: String
    let icon: String
    
    var body: some View {
        VStack(spacing: NGSize.spacing / 2) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(NGColor.primary)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(NGFont.bodyS)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(value)
                    .font(NGFont.titleM)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                
                Text("of \(target)")
                    .font(NGFont.bodyXS)
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(NGSize.corner)
        .frame(height: 100)
    }
}

// MARK: - Meal Card Component
struct MealCard: View {
    let mealType: String
    let calories: Int
    let time: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(mealType)
                    .font(NGFont.bodyM)
                    .foregroundColor(.white)
                    .fontWeight(.medium)
                
                Text(time)
                    .font(NGFont.bodyS)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(calories) cal")
                    .font(NGFont.bodyM)
                    .foregroundColor(.white)
                    .fontWeight(.medium)
                
                Button("View") {
                    // TODO: View meal details
                }
                .foregroundColor(NGColor.primary)
                .font(NGFont.bodyS)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(NGSize.corner)
    }
}

// MARK: - Add Meal Card Component
struct AddMealCard: View {
    let mealType: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(mealType)
                    .font(NGFont.bodyM)
                    .foregroundColor(.white.opacity(0.7))
                
                Text("Tap to add")
                    .font(NGFont.bodyS)
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            Image(systemName: "plus.circle")
                .foregroundColor(NGColor.primary)
                .font(.title2)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(NGSize.corner)
        .overlay(
            RoundedRectangle(cornerRadius: NGSize.corner)
                .stroke(Color.white.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [5]))
        )
        .onTapGesture {
            // TODO: Add meal action
        }
    }
}

// MARK: - Placeholder Views
struct MealLoggingView: View {
    var body: some View {
        HeroBaseView {
            VStack {
                Text("Meal Logging")
                    .font(NGFont.titleXL)
                    .foregroundColor(.white)
                
                Text("Coming Soon...")
                    .font(NGFont.bodyM)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}

struct ProgressView: View {
    var body: some View {
        HeroBaseView {
            VStack {
                Text("Progress Tracking")
                    .font(NGFont.titleXL)
                    .foregroundColor(.white)
                
                Text("Coming Soon...")
                    .font(NGFont.bodyM)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}

struct SettingsView: View {
    let router: AppRouter
    
    var body: some View {
        HeroBaseView {
            VStack(spacing: NGSize.spacing * 2) {
                Text("Settings")
                    .font(NGFont.titleXL)
                    .foregroundColor(.white)
                
                VStack(spacing: NGSize.spacing) {
                    SettingsRow(title: "Profile", icon: "person.fill") {
                        // TODO: Profile settings
                    }
                    
                    SettingsRow(title: "Notifications", icon: "bell.fill") {
                        // TODO: Notification settings
                    }
                    
                    SettingsRow(title: "Subscription", icon: "creditcard.fill") {
                        // TODO: Subscription settings
                    }
                    
                    SettingsRow(title: "Sign Out", icon: "rectangle.portrait.and.arrow.right", isDestructive: true) {
                        signOut(router: router)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    private func signOut(router: AppRouter) {
        do {
            try Auth.auth().signOut()
            router.to(.hero)
        } catch {
            print("❌ Sign out failed: \(error)")
        }
    }
}

struct SettingsRow: View {
    let title: String
    let icon: String
    let isDestructive: Bool
    let action: () -> Void
    
    init(title: String, icon: String, isDestructive: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isDestructive = isDestructive
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(isDestructive ? .red : .white)
                    .frame(width: 24)
                
                Text(title)
                    .font(NGFont.bodyM)
                    .foregroundColor(isDestructive ? .red : .white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.5))
                    .font(.caption)
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(NGSize.corner)
        }
    }
}
