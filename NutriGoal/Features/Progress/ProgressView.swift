import SwiftUI
import Charts

struct ProgressView: View {
    @StateObject private var viewModel = ProgressViewModel()
    
    var body: some View {
        NavigationView {
            HeroBaseView {
                ScrollView {
                    VStack(spacing: NGSize.spacing * 2) {
                        // Header
                        Text("📈 Progress")
                            .font(NGFont.titleL)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top)
                        
                        // Time period selector
                        Picker("Period", selection: $viewModel.selectedPeriod) {
                            Text("7 Days").tag(ProgressPeriod.week)
                            Text("30 Days").tag(ProgressPeriod.month)
                            Text("90 Days").tag(ProgressPeriod.threeMonths)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        .colorScheme(.dark)
                        
                        // Weight Chart
                        VStack(alignment: .leading, spacing: NGSize.spacing) {
                            Text("Weight Trend")
                                .font(NGFont.titleM)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            WeightChartCard(data: viewModel.weightData, period: viewModel.selectedPeriod)
                                .padding(.horizontal)
                        }
                        
                        // Calorie Chart
                        VStack(alignment: .leading, spacing: NGSize.spacing) {
                            Text("Daily Calories")
                                .font(NGFont.titleM)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            CalorieChartCard(data: viewModel.calorieData, target: viewModel.calorieTarget)
                                .padding(.horizontal)
                        }
                        
                        // Macro Breakdown
                        VStack(alignment: .leading, spacing: NGSize.spacing) {
                            Text("Average Macros")
                                .font(NGFont.titleM)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            MacroBreakdownCard(
                                protein: viewModel.avgProtein,
                                carbs: viewModel.avgCarbs,
                                fat: viewModel.avgFat
                            )
                            .padding(.horizontal)
                        }
                        
                        // Stats Summary
                        StatsGridView(
                            avgCalories: viewModel.avgCalories,
                            avgSteps: viewModel.avgSteps,
                            avgSleep: viewModel.avgSleep,
                            avgWorkout: viewModel.avgWorkout
                        )
                        .padding(.horizontal)
                        
                        Spacer(minLength: 100)
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadProgressData()
            }
        }
    }
}

// MARK: - Weight Chart Card
struct WeightChartCard: View {
    let data: [WeightDataPoint]
    let period: ProgressPeriod
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Current weight display
            if let latest = data.last {
                HStack(alignment: .bottom) {
                    Text(String(format: "%.1f", latest.weight))
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("kg")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.bottom, 6)
                    
                    Spacer()
                    
                    // Change indicator
                    if data.count > 1 {
                        let change = latest.weight - data.first!.weight
                        HStack(spacing: 4) {
                            Image(systemName: change < 0 ? "arrow.down" : "arrow.up")
                            Text(String(format: "%.1f kg", abs(change)))
                        }
                        .font(.caption)
                        .foregroundColor(change < 0 ? .green : .red)
                    }
                }
            }
            
            // Simple line chart
            if !data.isEmpty {
                Chart(data) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Weight", point.weight)
                    )
                    .foregroundStyle(.white)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    
                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value("Weight", point.weight)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white.opacity(0.3), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .frame(height: 150)
                .chartXAxis(.hidden)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel()
                            .foregroundStyle(.white.opacity(0.7))
                            .font(.caption)
                    }
                }
            } else {
                Text("No weight data yet")
                    .foregroundColor(.white.opacity(0.5))
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(NGSize.corner)
    }
}

// MARK: - Calorie Chart Card
struct CalorieChartCard: View {
    let data: [CalorieDataPoint]
    let target: Int
    
    var body: some View {
        VStack(spacing: 12) {
            if !data.isEmpty {
                Chart(data) { point in
                    BarMark(
                        x: .value("Date", point.date, unit: .day),
                        y: .value("Calories", point.calories)
                    )
                    .foregroundStyle(point.calories > target ? Color.red : Color.green)
                    
                    RuleMark(y: .value("Target", target))
                        .foregroundStyle(.white.opacity(0.3))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisValueLabel(format: .dateTime.day())
                            .foregroundStyle(.white.opacity(0.7))
                            .font(.caption)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel()
                            .foregroundStyle(.white.opacity(0.7))
                            .font(.caption)
                    }
                }
            } else {
                Text("No calorie data yet")
                    .foregroundColor(.white.opacity(0.5))
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(NGSize.corner)
    }
}

// MARK: - Macro Breakdown Card
struct MacroBreakdownCard: View {
    let protein: Int
    let carbs: Int
    let fat: Int
    
    private var total: Int {
        (protein * 4) + (carbs * 4) + (fat * 9)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                MacroStatCard(title: "Protein", value: "\(protein)g", color: Color(hex: "#FF6B6B"))
                MacroStatCard(title: "Carbs", value: "\(carbs)g", color: Color(hex: "#FFB74D"))
                MacroStatCard(title: "Fat", value: "\(fat)g", color: Color(hex: "#64B5F6"))
            }
            
            // Calorie breakdown
            Text("\(total) average daily calories")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(NGSize.corner)
    }
}

struct MacroStatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
}

// MARK: - Stats Grid
struct StatsGridView: View {
    let avgCalories: Int
    let avgSteps: Int
    let avgSleep: Double
    let avgWorkout: Int
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(icon: "flame.fill", title: "Avg Calories", value: "\(avgCalories)")
            StatCard(icon: "figure.walk", title: "Avg Steps", value: "\(avgSteps)")
            StatCard(icon: "bed.double.fill", title: "Avg Sleep", value: String(format: "%.1fh", avgSleep))
            StatCard(icon: "dumbbell.fill", title: "Workouts", value: "\(avgWorkout)m")
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(NGSize.corner)
    }
}

#Preview {
    ProgressView()
}

