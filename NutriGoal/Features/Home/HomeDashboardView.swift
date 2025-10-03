import SwiftUI
import PhotosUI

struct HomeDashboardView: View {
    @StateObject private var viewModel = HomeDashboardViewModel()
    @State private var showMealSheet = false
    @State private var selectedDate = Date()
    @State private var showPhotoPicker = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Hero-style gradient background
                HeroBaseView {
                    Color.clear
                }
                
                ScrollView {
                    ScrollView {
                        VStack(spacing: NGSize.spacing * 2) {
                            // Header
                            HStack {
                                Text("🔥 NutriGoal")
                                    .font(NGFont.titleL)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            
                            // Week Calendar
                            WeekCalendarView(selectedDate: $selectedDate)
                                .padding(.horizontal)
                            
                            // Main Calorie Ring
                            VStack(spacing: 8) {
                                ZStack {
                                    // Background ring
                                    Circle()
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 12)
                                        .frame(width: 140, height: 140)
                                    
                                    // Progress ring
                                    Circle()
                                        .trim(from: 0, to: min(Double(viewModel.caloriesConsumed) / Double(viewModel.caloriesTarget), 1.0))
                                        .stroke(Color.white, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                                        .frame(width: 140, height: 140)
                                        .rotationEffect(.degrees(-90))
                                        .animation(.easeInOut(duration: 0.5), value: viewModel.caloriesConsumed)
                                    
                                    // Center content
                                    VStack(spacing: 2) {
                                        Text("🔥")
                                            .font(.title)
                                        
                                        Text("\(max(0, viewModel.caloriesTarget - viewModel.caloriesConsumed))")
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                                
                                Text("Calories \(viewModel.caloriesConsumed >= viewModel.caloriesTarget ? "over" : "left")")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical)
                            
                            // Macro Rings
                            HStack(spacing: NGSize.spacing * 2) {
                                MacroRing(
                                    value: viewModel.proteinConsumed,
                                    target: viewModel.proteinTarget,
                                    label: "Protein",
                                    unit: "g",
                                    color: Color(hex: "#FF6B6B")
                                )
                                
                                MacroRing(
                                    value: viewModel.carbsConsumed,
                                    target: viewModel.carbsTarget,
                                    label: "Carbs",
                                    unit: "g",
                                    color: Color(hex: "#FFB74D")
                                )
                                
                                MacroRing(
                                    value: viewModel.fatConsumed,
                                    target: viewModel.fatTarget,
                                    label: "Fats",
                                    unit: "g",
                                    color: Color(hex: "#64B5F6")
                                )
                            }
                            .padding(.horizontal)
                            
                        // Recently Logged Section
                        VStack(alignment: .leading, spacing: NGSize.spacing) {
                            Text("Recently logged")
                                .font(NGFont.titleM)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            // Show analyzing state if processing
                            if viewModel.isAnalyzingFood {
                                AnalyzingFoodCard(progress: viewModel.analysisProgress)
                                    .padding(.horizontal)
                            }
                                
                                if viewModel.meals.isEmpty {
                                    EmptyMealsView()
                                        .padding(.horizontal)
                                } else {
                                    VStack(spacing: NGSize.spacing) {
                                        ForEach(viewModel.meals, id: \.id) { meal in
                                            CalAIMealCard(meal: meal)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            Spacer(minLength: 100)
                        }
                    }
                    .ignoresSafeArea(edges: .top)
                    
                    // FAB (Cal AI style)
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: { showPhotoPicker = true }) {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 56, height: 56)
                                    .background(NGColor.primary)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                            }
                            .padding(.trailing, NGSize.spacing * 2)
                            .padding(.bottom, NGSize.spacing * 6)
                        }
                    }
                }
            }
        .sheet(isPresented: $showPhotoPicker) {
            PhotosPicker(selection: $viewModel.selectedPhotoItem, matching: .images) {
                Text("Select Food Photo")
            }
            .onChange(of: viewModel.selectedPhotoItem) { _ in
                showPhotoPicker = false
                Task {
                    await viewModel.processSelectedPhoto()
                }
            }
        }
            .onAppear {
                Task {
                    await viewModel.loadUserGoals()
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
    
    // MARK: - Week Calendar (Dark Style)
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
                                .fill(isSelected(date) ? .white : Color.clear)
                                .frame(width: 32, height: 32)
                            
                            Text("\(Calendar.current.component(.day, from: date))")
                                .font(.subheadline)
                                .fontWeight(isSelected(date) ? .bold : .medium)
                                .foregroundColor(isSelected(date) ? .black : .white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        selectedDate = date
                    }
                }
            }
            .padding(.vertical, NGSize.spacing)
            .background(Color.white.opacity(0.15))
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
    
    // MARK: - Macro Ring (Cal AI Style)
    struct MacroRing: View {
        let value: Int
        let target: Int
        let label: String
        let unit: String
        let color: Color
        
        private var progress: Double {
            guard target > 0 else { return 0 }
            return Double(value) / Double(target)
        }
        
        private var difference: Int {
            target - value
        }
        
        private var status: String {
            value >= target ? "over" : "left"
        }
        
        var body: some View {
            VStack(spacing: 8) {
                ZStack {
                    // Background ring
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    // Progress ring
                    Circle()
                        .trim(from: 0, to: min(progress, 1.0))
                        .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: progress)
                    
                    // Center value
                    Text("\(abs(difference))\(unit)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Label
                Text("\(label) \(status)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
    
    // MARK: - Cal AI Style Meal Card
    struct CalAIMealCard: View {
        let meal: Meal
        
        var body: some View {
            HStack(spacing: 12) {
                // Meal photo thumbnail
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: meal.source == "photo" ? "photo.fill" : "fork.knife")
                            .font(.title2)
                            .foregroundColor(.gray)
                    )
                
                // Meal info
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(meal.name)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text(meal.loggedAt.formatted(date: .omitted, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    // Calorie badge
                    HStack {
                        Image(systemName: "flame.fill")
                            .font(.caption)
                            .foregroundColor(.white)
                        Text("\(meal.calories) kcal")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(6)
                    
                    // Macro badges
                    HStack(spacing: 8) {
                        MacroBadge(icon: "⚡️", value: "\(meal.proteinG)g", color: Color(hex: "#FF6B6B"))
                        MacroBadge(icon: "🌾", value: "\(meal.carbsG)g", color: Color(hex: "#FFB74D"))
                        MacroBadge(icon: "🥑", value: "\(meal.fatG)g", color: Color(hex: "#64B5F6"))
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color.white.opacity(0.15))
            .cornerRadius(16)
        }
    }
    
    // MARK: - Macro Badge
    struct MacroBadge: View {
        let icon: String
        let value: String
        let color: Color
        
        var body: some View {
            HStack(spacing: 4) {
                Text(icon)
                    .font(.caption2)
                Text(value)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(color)
            }
        }
    }
    
// MARK: - Empty Meals View (Dark Style)
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
        .padding(.vertical, NGSize.spacing * 3)
        .background(Color.white.opacity(0.05))
        .cornerRadius(NGSize.corner)
    }
}

// MARK: - Analyzing Food Card (Cal AI Style)
struct AnalyzingFoodCard: View {
    let progress: Double
    
    var body: some View {
        HStack(spacing: 16) {
            // Food image with progress ring
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                // Progress ring
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 4)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.3), value: progress)
                
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            // Analyzing text
            VStack(alignment: .leading, spacing: 4) {
                Text("Analyzing food...")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text("We'll notify you when done!")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(16)
    }
}

}
