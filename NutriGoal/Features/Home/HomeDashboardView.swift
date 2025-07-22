import SwiftUI

struct HomeDashboardView: View {
    @StateObject private var viewModel = HomeDashboardViewModel()
    @State private var showMealSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                HeroBaseView {
                    ScrollView {
                        VStack(spacing: NGSize.spacing * 2) {
                            // Header
                            VStack(spacing: NGSize.spacing / 2) {
                                Text("Today's Progress")
                                    .font(NGFont.titleXL)
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
                                        .font(NGFont.titleXL)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                }
                                
                                if viewModel.meals.isEmpty {
                                    VStack(spacing: NGSize.spacing) {
                                        Image(systemName: "fork.knife")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white.opacity(0.5))
                                        
                                        Text("No meals logged today")
                                            .font(NGFont.bodyM)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, NGSize.spacing * 2)
                                } else {
                                    VStack(spacing: NGSize.spacing / 2) {
                                        ForEach(viewModel.meals, id: \.id) { meal in
                                            MealRow(meal: meal)
                                        }
                                    }
                                }
                            }
                            
                            Spacer(minLength: 100) // Extra space for FAB
                        }
                        .padding()
                    }
                }
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingActionButton {
                            showMealSheet = true
                        }
                        .padding(.trailing, NGSize.spacing * 2)
                        .padding(.bottom, NGSize.spacing * 6) // Account for tab bar
                    }
                }
            }
        }
        .sheet(isPresented: $showMealSheet) {
            MealLoggingView()
        }
        .onAppear {
            Task { await viewModel.loadMeals() }
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
                Text(title)
                    .font(NGFont.bodyM)
                    .foregroundColor(.white)
                Spacer()
            }
            
            HStack {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
                Text("/ \(target)")
                    .font(NGFont.bodyM)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(NGSize.corner)
    }
}

// MARK: - Meal Row Component
struct MealRow: View {
    let meal: Meal
    
    var body: some View {
        HStack(spacing: NGSize.spacing) {
            // Meal Icon
            Image(systemName: meal.source == "photo" ? "camera.fill" : "fork.knife")
                .foregroundColor(NGColor.primary)
                .frame(width: 20)
            
            // Meal Info
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.name)
                    .font(NGFont.bodyM)
                    .foregroundColor(.white)
                
                Text(meal.loggedAt.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            // Calories
            Text("\(meal.calories) kcal")
                .font(NGFont.bodyM)
                .foregroundColor(.white)
                .fontWeight(.medium)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(NGSize.corner)
    }
}

// MARK: - Floating Action Button
struct FloatingActionButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(NGColor.primary)
                .clipShape(Circle())
                .shadow(radius: 4)
        }
    }
}

#Preview {
    HomeDashboardView()
} 