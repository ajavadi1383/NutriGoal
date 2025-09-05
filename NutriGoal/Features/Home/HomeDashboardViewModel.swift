import Foundation
import SwiftUI

@MainActor
final class HomeDashboardViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let firebaseService: FirebaseService
    private let healthKitService: HealthKitService
    
    // MARK: - Published Properties
    @Published var meals: [Meal] = []
    @Published var isLoading = false
    @Published var selectedDate = Date()
    
    // Health data (from HealthKit)
    @Published var steps = 0
    @Published var stepsTarget = 10000
    @Published var caloriesBurned = 0.0
    @Published var sleepHours = 0.0
    @Published var workoutMinutes = 0
    
    // Nutrition data (calculated from meals)
    @Published var caloriesConsumed = 0
    @Published var proteinConsumed = 0
    @Published var carbsConsumed = 0
    @Published var fatConsumed = 0
    @Published var caloriesTarget = 2100
    @Published var waterOunces = 24
    
    // MARK: - Init
    init(
        firebaseService: FirebaseService = FirebaseServiceImpl(),
        healthKitService: HealthKitService? = nil
    ) {
        self.firebaseService = firebaseService
        self.healthKitService = healthKitService ?? HealthKitServiceImpl()
        setupNotifications()
    }
    
    // MARK: - Setup
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: .mealAdded,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { 
                await self?.loadMeals()
                await self?.loadHealthData()
            }
        }
    }
    
    // MARK: - Load Data
    func loadMeals() async {
        isLoading = true
        
        do {
            meals = try await firebaseService.fetchMeals(for: selectedDate)
            print("✅ [HomeDashboardViewModel] Loaded \(meals.count) meals for today")
            await updateNutritionStats()
        } catch {
            print("❌ [HomeDashboardViewModel] Failed to load meals: \(error)")
            meals = []
            resetNutritionStats()
        }
        
        isLoading = false
    }
    
    func loadHealthData() async {
        do {
            // Request permissions first time
            let permissionsGranted = try await healthKitService.requestPermissions()
            guard permissionsGranted else {
                print("⚠️ [HomeDashboardViewModel] HealthKit permissions not granted")
                return
            }
            
            // Load health data for selected date
            steps = try await healthKitService.getSteps(for: selectedDate)
            caloriesBurned = try await healthKitService.getActiveCalories(for: selectedDate)
            sleepHours = try await healthKitService.getSleepHours(for: selectedDate)
            workoutMinutes = try await healthKitService.getWorkoutMinutes(for: selectedDate)
            
            print("✅ [HomeDashboardViewModel] Health data loaded: \(steps) steps, \(caloriesBurned) cal burned")
            
        } catch {
            print("❌ [HomeDashboardViewModel] Failed to load health data: \(error)")
            // Keep default values on error
        }
    }
    
    private func updateNutritionStats() async {
        // Calculate nutrition totals from actual logged meals
        caloriesConsumed = meals.reduce(0) { $0 + $1.calories }
        proteinConsumed = meals.reduce(0) { $0 + $1.proteinG }
        carbsConsumed = meals.reduce(0) { $0 + $1.carbsG }
        fatConsumed = meals.reduce(0) { $0 + $1.fatG }
        
        print("📊 [HomeDashboardViewModel] Nutrition stats: \(caloriesConsumed) cal, \(proteinConsumed)g protein, \(carbsConsumed)g carbs, \(fatConsumed)g fat")
    }
    
    private func resetNutritionStats() {
        caloriesConsumed = 0
        proteinConsumed = 0
        carbsConsumed = 0
        fatConsumed = 0
        print("🔄 [HomeDashboardViewModel] Reset nutrition stats to 0 (no meals)")
    }
    
    // MARK: - Date Selection
    func selectDate(_ date: Date) {
        selectedDate = date
        Task { await loadMeals() }
    }
    
    // MARK: - Cleanup
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}