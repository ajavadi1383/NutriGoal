import SwiftUI

struct HomeDashboardView: View {
    @StateObject private var viewModel = HomeDashboardViewModel()
    @State private var showMealSheet = false
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            ZStack {
                // White background like Cal AI
                Color.white
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: NGSize.spacing * 1.5) {
                        // Header with App Name
                        HStack {
                            VStack(alignment: .leading) {
                                Text("🔥 NutriGoal")
                                    .font(NGFont.titleL)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                            }
                            
                            Spacer()
                            
                            // Notification badge
                            ZStack {
                                Circle()
                                    .fill(NGColor.secondary)
                                    .frame(width: 24, height: 24)
                                
                                Text("1")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Week Calendar
                        WeekCalendarView(selectedDate: $selectedDate)
                            .padding(.horizontal)
                        
                        // Main Stats Section
                        VStack(spacing: NGSize.spacing) {
                            HStack(spacing: NGSize.spacing) {
                                // Steps Card
                                StatsCard(
                                    title: "Steps today",
                                    value: "\(viewModel.steps)",
                                    target: "/\(viewModel.stepsTarget)",
                                    icon: "figure.walk",
                                    color: .black
                                )
                                
                                // Calories Card
                                StatsCard(
                                    title: "Calories burned",
                                    value: "\(Int(viewModel.caloriesBurned))",
                                    target: "",
                                    icon: "flame.fill",
                                    color: NGColor.accent
                                )
                            }
                            
                            // Circular Progress Ring
                            CalorieProgressRing(
                                consumed: viewModel.caloriesConsumed,
                                target: viewModel.caloriesTarget,
                                steps: viewModel.steps,
                                targetSteps: viewModel.stepsTarget
                            )
                            .padding(.vertical)
                            
                            // Water Section
                            WaterTrackingCard()
                        }
                        .padding(.horizontal)
                        
                        // Recently Logged Section
                        VStack(alignment: .leading, spacing: NGSize.spacing) {
                            HStack {
                                Text("Recently logged")
                                    .font(NGFont.titleM)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            if viewModel.meals.isEmpty {
                                EmptyMealsView()
                                    .padding(.horizontal)
                            } else {
                                VStack(spacing: NGSize.cardSpacing) {
                                    ForEach(viewModel.meals, id: \.id) { meal in
                                        MealLogCard(meal: meal)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        Spacer(minLength: 100) // Space for FAB
                    }
                }
                
                // Floating Action Button (Cal AI style)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showMealSheet = true }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(.black)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, NGSize.spacing * 2)
                        .padding(.bottom, NGSize.spacing * 6)
                    }
                }
            }
        }
        .sheet(isPresented: $showMealSheet) {
            MealLoggingView()
        }
        .onAppear {
            Task { 
                await viewModel.loadMeals()
                await viewModel.loadHealthData()
            }
        }
        .onChange(of: selectedDate) { _ in
            Task {
                await viewModel.loadMeals()
                await viewModel.loadHealthData()
            }
        }
    }
}

// MARK: - Week Calendar
struct WeekCalendarView: View {
    @Binding var selectedDate: Date
    
    private var weekDays: [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekDays, id: \.self) { date in
                VStack(spacing: 4) {
                    Text(dayLetter(for: date))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                    
                    ZStack {
                        Circle()
                            .fill(isSelected(date) ? .black : Color.clear)
                            .frame(width: 32, height: 32)
                        
                        Text("\(Calendar.current.component(.day, from: date))")
                            .font(.subheadline)
                            .fontWeight(isSelected(date) ? .bold : .medium)
                            .foregroundColor(isSelected(date) ? .white : .black)
                    }
                }
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    selectedDate = date
                }
            }
        }
        .padding(.vertical, NGSize.spacing)
        .background(NGColor.cardBackground)
        .cornerRadius(NGSize.corner)
    }
    
    private func dayLetter(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }
    
    private func isSelected(_ date: Date) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
}

// MARK: - Stats Card
struct StatsCard: View {
    let title: String
    let value: String
    let target: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: NGSize.cardSpacing) {
            HStack {
                Text(title)
                    .font(NGFont.bodyS)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Image(systemName: icon)
                    .foregroundColor(color)
            }
            
            HStack(alignment: .bottom, spacing: 2) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text(target)
                    .font(NGFont.bodyS)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(NGColor.cardBackground)
        .cornerRadius(NGSize.corner)
    }
}

// MARK: - Calorie Progress Ring
struct CalorieProgressRing: View {
    let consumed: Int
    let target: Int
    let steps: Int
    let targetSteps: Int
    
    private var progress: Double {
        Double(consumed) / Double(target)
    }
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                .frame(width: 120, height: 120)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(.black, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
            
            // Center content
            VStack(spacing: 2) {
                Text("🔥")
                    .font(.title)
                
                Text("\(consumed)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
        }
        .overlay(
            // Side stats
            VStack {
                HStack {
                    Spacer()
                    VStack(alignment: .leading, spacing: 4) {
                        StatBadge(icon: "figure.walk", value: "\(viewModel.steps)", label: "Steps")
                        StatBadge(icon: "dumbbell.fill", value: "\(Int(viewModel.caloriesBurned))", label: "Cal burned")
                    }
                    .padding(.leading, 140)
                }
                Spacer()
            }
        )
    }
}

// MARK: - Stat Badge
struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(.black)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Water Tracking Card
struct WaterTrackingCard: View {
    @State private var waterAmount = 24
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "drop.fill")
                        .foregroundColor(.blue)
                    Text("Water")
                        .font(NGFont.bodyM)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                }
                
                Text("\(waterAmount) fl oz (3 cups)")
                    .font(NGFont.bodyS)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: { waterAmount = max(0, waterAmount - 8) }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                
                Button(action: { waterAmount += 8 }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.black)
                }
            }
        }
        .padding()
        .background(NGColor.cardBackground)
        .cornerRadius(NGSize.corner)
    }
}

// MARK: - Meal Log Card
struct MealLogCard: View {
    let meal: Meal
    
    var body: some View {
        HStack(spacing: NGSize.spacing) {
            // Meal Image Placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(NGColor.cardBackground)
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: meal.source == "photo" ? "photo.fill" : "fork.knife")
                        .foregroundColor(.gray)
                )
            
            // Meal Info
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.name)
                    .font(NGFont.bodyM)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                
                Text(meal.loggedAt.formatted(date: .omitted, time: .shortened))
                    .font(NGFont.caption)
                    .foregroundColor(.gray)
                
                HStack(spacing: 12) {
                    MacroChip(icon: "flame.fill", value: "\(meal.calories)", unit: "calories", color: NGColor.accent)
                    MacroChip(icon: "leaf.fill", value: "\(meal.proteinG)", unit: "g", color: .red)
                    MacroChip(icon: "circle.fill", value: "\(meal.carbsG)", unit: "g", color: .orange)
                    MacroChip(icon: "drop.fill", value: "\(meal.fatG)", unit: "g", color: .blue)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(.white)
        .cornerRadius(NGSize.corner)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Macro Chip
struct MacroChip: View {
    let icon: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(color)
            
            Text("\(value)\(unit == "g" ? "g" : "")")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.black)
        }
    }
}

// MARK: - Empty Meals View
struct EmptyMealsView: View {
    var body: some View {
        VStack(spacing: NGSize.spacing) {
            Image(systemName: "fork.knife")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No meals logged today")
                .font(NGFont.bodyM)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, NGSize.spacing * 2)
        .background(NGColor.cardBackground)
        .cornerRadius(NGSize.corner)
    }
}

#Preview {
    HomeDashboardView()
}