//
//  RootView.swift
//  NutriGoal
//
//  Created by Amirali Javadi on 6/7/25.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var diContainer: DIContainer
    @State private var authState: AuthState = .loading
    @State private var isFirstLaunch = true
    @State private var needsOnboarding = false
    @State private var isOnboardingComplete = false
    
    var body: some View {
        Group {
            switch authState {
            case .loading:
                LoadingView()
            case .unauthenticated:
                if isFirstLaunch {
                    WelcomeView(onGetStarted: {
                        // Navigate to onboarding
                        needsOnboarding = true
                    })
                } else {
                    LoginView()
                }
            case .authenticated(let user):
                MainTabView(user: user)
            }
        }
        .fullScreenCover(isPresented: $needsOnboarding) {
            OnboardingFlow(isOnboardingComplete: $isOnboardingComplete)
        }
        .onChange(of: isOnboardingComplete) { completed in
            if completed {
                needsOnboarding = false
                // Refresh auth state to load the new user
                Task {
                    await checkAuthenticationState()
                }
            }
        }
        .task {
            await checkAuthenticationState()
        }
    }
    
    private func checkAuthenticationState() async {
        // Check if user is already logged in
        let isLoggedIn = diContainer.authenticationUseCase.isUserLoggedIn()
        
        if isLoggedIn {
            do {
                if let user = try await diContainer.authenticationUseCase.getCurrentUser() {
                    authState = .authenticated(user)
                } else {
                    authState = .unauthenticated
                }
            } catch {
                authState = .unauthenticated
            }
        } else {
            authState = .unauthenticated
        }
    }
}

// MARK: - Loading View

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                
                Text("NutriGoal")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
            }
        }
    }
}

// MARK: - Welcome View

struct WelcomeView: View {
    let onGetStarted: () -> Void
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                VStack(spacing: 20) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    
                    Text("Welcome to")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text("NutriGoal")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 16) {
                    FeatureRow(
                        icon: "brain.head.profile",
                        title: "AI-Powered Journaling",
                        description: "Get personalized daily insights"
                    )
                    
                    FeatureRow(
                        icon: "message.badge.filled",
                        title: "Personal AI Coach",
                        description: "24/7 motivation and support"
                    )
                    
                    FeatureRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Lifestyle Scoring",
                        description: "Track your progress holistically"
                    )
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button(action: {
                        onGetStarted()
                    }) {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        // Navigate to sign in
                    }) {
                        Text("I already have an account")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Login View (Placeholder)

struct LoginView: View {
    var body: some View {
        VStack {
            Text("Login View")
                .font(.title)
            Text("(To be implemented in Phase 2)")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Main Tab View (Placeholder)

struct MainTabView: View {
    let user: User
    
    var body: some View {
        TabView {
            DashboardView(user: user)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            Text("Food Logging")
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("Log Food")
                }
            
            Text("Journal")
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Journal")
                }
            
            Text("Chat Coach")
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Coach")
                }
            
            Text("Profile")
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .accentColor(.blue)
    }
}

// MARK: - Dashboard View (Basic Implementation)

struct DashboardView: View {
    let user: User
    @EnvironmentObject var diContainer: DIContainer
    @State private var lifestyleScore: Double = 0.0
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Welcome back!")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Here's your progress for today")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Lifestyle Score Card
                    VStack(spacing: 16) {
                        Text("Today's Lifestyle Score")
                            .font(.headline)
                        
                        if isLoading {
                            ProgressView()
                                .scaleEffect(1.2)
                        } else {
                            VStack(spacing: 8) {
                                Text("\(lifestyleScore, specifier: "%.1f")")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.blue)
                                
                                Text("out of 10")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Text(getScoreDescription(lifestyleScore))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Actions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            QuickActionCard(
                                icon: "plus.circle.fill",
                                title: "Log Meal",
                                subtitle: "Add your food",
                                color: .green
                            )
                            
                            QuickActionCard(
                                icon: "message.fill",
                                title: "AI Coach",
                                subtitle: "Get motivation",
                                color: .purple
                            )
                            
                            QuickActionCard(
                                icon: "book.fill",
                                title: "Journal",
                                subtitle: "Daily insights",
                                color: .orange
                            )
                            
                            QuickActionCard(
                                icon: "chart.bar.fill",
                                title: "Progress",
                                subtitle: "View trends",
                                color: .blue
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationTitle("NutriGoal")
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            await loadDashboardData()
        }
    }
    
    private func loadDashboardData() async {
        do {
            let score = try await diContainer.lifestyleScoreUseCase.calculateTodaysScore()
            await MainActor.run {
                self.lifestyleScore = score.overallScore
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.lifestyleScore = 0.0
                self.isLoading = false
            }
        }
    }
    
    private func getScoreDescription(_ score: Double) -> String {
        switch score {
        case 9...10:
            return "Excellent! You're crushing your goals! 🎉"
        case 7..<9:
            return "Great work! Keep up the momentum! 💪"
        case 5..<7:
            return "Good progress! Small improvements matter! 👍"
        case 3..<5:
            return "You're building habits! Every step counts! 🌱"
        default:
            return "New beginnings! Let's start your journey! 🚀"
        }
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    RootView()
        .environmentObject(DIContainer.shared)
} 