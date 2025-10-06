import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    let router: AppRouter
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationView {
            HeroBaseView {
                ScrollView {
                    VStack(spacing: NGSize.spacing * 2) {
                        // Header
                        VStack(spacing: 8) {
                            Text("⚙️ Settings")
                                .font(NGFont.titleL)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            if let email = Auth.auth().currentUser?.email {
                                Text(email)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .padding(.top)
                        
                        // Profile Section
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Profile")
                            
                            SettingsButton(
                                icon: "person.fill",
                                title: "Edit Profile",
                                subtitle: "Update your personal information"
                            ) {
                                viewModel.editProfileTapped()
                            }
                            
                            SettingsButton(
                                icon: "target",
                                title: "Goals & Targets",
                                subtitle: "Adjust your nutrition goals"
                            ) {
                                viewModel.goalsTapped()
                            }
                            
                            SettingsButton(
                                icon: "fork.knife",
                                title: "Dietary Preferences",
                                subtitle: viewModel.dietType.capitalized
                            ) {
                                viewModel.dietPreferencesTapped()
                            }
                        }
                        .padding(.horizontal)
                        
                        // Data & Privacy Section
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Data & Privacy")
                            
                            SettingsButton(
                                icon: "heart.fill",
                                title: "HealthKit Connection",
                                subtitle: viewModel.healthKitConnected ? "Connected" : "Not connected"
                            ) {
                                Task {
                                    await viewModel.toggleHealthKit()
                                }
                            }
                            
                            SettingsButton(
                                icon: "arrow.down.circle.fill",
                                title: "Export Data",
                                subtitle: "Download your nutrition data"
                            ) {
                                viewModel.exportDataTapped()
                            }
                        }
                        .padding(.horizontal)
                        
                        // App Settings Section
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "App Settings")
                            
                            SettingsButton(
                                icon: "bell.fill",
                                title: "Notifications",
                                subtitle: "Meal reminders and updates"
                            ) {
                                viewModel.notificationsTapped()
                            }
                            
                            SettingsButton(
                                icon: "globe",
                                title: "Language",
                                subtitle: viewModel.languageName
                            ) {
                                viewModel.languageTapped()
                            }
                            
                            SettingsButton(
                                icon: "moon.fill",
                                title: "Theme",
                                subtitle: "Gradient (Hero style)"
                            ) {
                                viewModel.themeTapped()
                            }
                        }
                        .padding(.horizontal)
                        
                        // Subscription Section
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Subscription")
                            
                            SettingsButton(
                                icon: "creditcard.fill",
                                title: "Manage Subscription",
                                subtitle: "Premium - $20/month"
                            ) {
                                viewModel.subscriptionTapped()
                            }
                            
                            SettingsButton(
                                icon: "gift.fill",
                                title: "Restore Purchases",
                                subtitle: "Recover your subscription"
                            ) {
                                viewModel.restorePurchasesTapped()
                            }
                        }
                        .padding(.horizontal)
                        
                        // Danger Zone
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Account")
                            
                            SettingsButton(
                                icon: "arrow.right.square.fill",
                                title: "Sign Out",
                                subtitle: "",
                                isDestructive: true
                            ) {
                                viewModel.signOutTapped(router: router)
                            }
                            
                            SettingsButton(
                                icon: "trash.fill",
                                title: "Delete Account",
                                subtitle: "Permanently delete all your data",
                                isDestructive: true
                            ) {
                                viewModel.deleteAccountTapped()
                            }
                        }
                        .padding(.horizontal)
                        
                        // App Info
                        VStack(spacing: 4) {
                            Text("NutriGoal v1.0")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                            
                            Text("Made with ❤️ for healthier living")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .padding(.top)
                        
                        Spacer(minLength: 100)
                    }
                }
            }
        }
        .alert("Delete Account", isPresented: $viewModel.showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.confirmDeleteAccount(router: router)
                }
            }
        } message: {
            Text("This will permanently delete your account and all data. This action cannot be undone.")
        }
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.white.opacity(0.6))
            .textCase(.uppercase)
            .tracking(1)
    }
}

// MARK: - Settings Button
struct SettingsButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let isDestructive: Bool
    let action: () -> Void
    
    init(
        icon: String,
        title: String,
        subtitle: String,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.isDestructive = isDestructive
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isDestructive ? .red : .white)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(isDestructive ? .red : .white)
                    
                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(NGSize.corner)
        }
    }
}

#Preview {
    SettingsView(router: AppRouter())
}

