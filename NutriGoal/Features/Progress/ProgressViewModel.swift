import Foundation
import SwiftUI

enum ProgressPeriod: String, CaseIterable {
    case week = "7 Days"
    case month = "30 Days"
    case threeMonths = "90 Days"
    
    var days: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .threeMonths: return 90
        }
    }
}

struct WeightDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let weight: Double
}

struct CalorieDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let calories: Int
}

@MainActor
final class ProgressViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let firebaseService: FirebaseService
    private let healthKitService: HealthKitService
    
    // MARK: - Published Properties
    @Published var selectedPeriod: ProgressPeriod = .week
    @Published var weightData: [WeightDataPoint] = []
    @Published var calorieData: [CalorieDataPoint] = []
    @Published var isLoading = false
    
    // Average stats
    @Published var avgCalories = 0
    @Published var avgProtein = 0
    @Published var avgCarbs = 0
    @Published var avgFat = 0
    @Published var avgSteps = 0
    @Published var avgSleep = 0.0
    @Published var avgWorkout = 0
    @Published var calorieTarget = 2100
    
    // MARK: - Init
    init(
        firebaseService: FirebaseService = FirebaseServiceImpl(),
        healthKitService: HealthKitService = HealthKitServiceImpl()
    ) {
        self.firebaseService = firebaseService
        self.healthKitService = healthKitService
    }
    
    // MARK: - Load Progress Data
    func loadProgressData() async {
        isLoading = true
        
        let days = selectedPeriod.days
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -days, to: endDate) else {
            isLoading = false
            return
        }
        
        do {
            // Fetch real weight logs
            let weightLogs = try await firebaseService.fetchWeightLogs(from: startDate, to: endDate)
            weightData = weightLogs.map { WeightDataPoint(date: $0.loggedAt, weight: $0.weightKg) }
            print("✅ [ProgressViewModel] Loaded \(weightData.count) weight logs from Firestore")
            
            // Fetch real dayStats for calorie data
            let dayStats = try await firebaseService.fetchDayStatsRange(from: startDate, to: endDate)
            calorieData = dayStats.compactMap { stat in
                guard let date = DateFormatter.yyyyMMdd.date(from: stat.date) else { return nil }
                return CalorieDataPoint(date: date, calories: stat.caloriesTotal)
            }
            print("✅ [ProgressViewModel] Loaded \(calorieData.count) day stats from Firestore")
            
            // Calculate real averages from dayStats
            if !dayStats.isEmpty {
                avgCalories = dayStats.map(\.caloriesTotal).reduce(0, +) / dayStats.count
                avgProtein = dayStats.map(\.proteinTotal).reduce(0, +) / dayStats.count
                avgCarbs = dayStats.map(\.carbsTotal).reduce(0, +) / dayStats.count
                avgFat = dayStats.map(\.fatTotal).reduce(0, +) / dayStats.count
                avgSteps = dayStats.map(\.steps).reduce(0, +) / dayStats.count
                avgWorkout = dayStats.map(\.workoutMin).reduce(0, +) / dayStats.count
                avgSleep = Double(dayStats.map(\.sleepMin).reduce(0, +)) / Double(dayStats.count) / 60.0
            }
            
            // Get calorie target from onboarding data
            if let onboardingData = UserDefaults.standard.object(forKey: "onboardingData") as? [String: Any],
               let birthDate = onboardingData["birthDate"] as? Date,
               let sex = onboardingData["sex"] as? String,
               let heightCm = onboardingData["heightCm"] as? Int,
               let weightKg = onboardingData["weightKg"] as? Double,
               let activityLevel = onboardingData["activityLevel"] as? String,
               let target = onboardingData["target"] as? String,
               let weeklyPaceKg = onboardingData["weeklyPaceKg"] as? Double {
                
                let goals = NutritionCalculator.calculateDailyGoals(
                    birthDate: birthDate,
                    sex: sex,
                    heightCm: heightCm,
                    weightKg: weightKg,
                    activityLevel: activityLevel,
                    target: target,
                    weeklyPaceKg: weeklyPaceKg
                )
                calorieTarget = goals.calories
            }
            
            print("📊 [ProgressViewModel] Averages: \(avgCalories) cal, \(avgProtein)g protein, \(avgSteps) steps")
            
        } catch {
            print("❌ [ProgressViewModel] Failed to load progress data: \(error)")
        }
        
        isLoading = false
    }
}

