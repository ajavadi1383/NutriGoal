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
        
        // Generate sample data for now
        // TODO: Replace with real Firestore queries
        await generateSampleData()
        
        isLoading = false
    }
    
    // MARK: - Sample Data Generation
    private func generateSampleData() async {
        let days = selectedPeriod.days
        let calendar = Calendar.current
        
        // Weight data (gradual decrease for weight loss)
        weightData = (0..<days).compactMap { dayOffset in
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else { return nil }
            let baseWeight = 75.0
            let trend = Double(dayOffset) * 0.08 // Slight weight loss trend
            return WeightDataPoint(date: date, weight: baseWeight + trend + Double.random(in: -0.3...0.3))
        }.reversed()
        
        // Calorie data
        calorieData = (0..<min(days, 14)).compactMap { dayOffset in
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else { return nil }
            return CalorieDataPoint(date: date, calories: Int.random(in: 1800...2300))
        }.reversed()
        
        // Calculate averages
        if !calorieData.isEmpty {
            avgCalories = calorieData.map(\.calories).reduce(0, +) / calorieData.count
        }
        
        avgProtein = 120
        avgCarbs = 200
        avgFat = 60
        avgSteps = 8500
        avgSleep = 7.2
        avgWorkout = 45
        
        print("✅ [ProgressViewModel] Loaded \(weightData.count) weight points, \(calorieData.count) calorie points")
    }
}

