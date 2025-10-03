import Foundation
import SwiftUI
import PhotosUI

@MainActor
final class HomeDashboardViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let firebaseService: FirebaseService
    private let healthKitService: HealthKitService
    private let foodRecognitionService: FoodRecognitionService
    
    // MARK: - Published Properties
    @Published var meals: [Meal] = []
    @Published var isLoading = false
    @Published var selectedDate = Date()
    
    // Photo picker and analysis
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var isAnalyzingFood = false
    @Published var analysisProgress = 0.0
    
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
    
    // Nutrition goals (from user profile)
    @Published var caloriesTarget = 2100
    @Published var proteinTarget = 131
    @Published var carbsTarget = 236
    @Published var fatTarget = 70
    @Published var waterOunces = 24
    
    // MARK: - Init
    init(
        firebaseService: FirebaseService = FirebaseServiceImpl(),
        healthKitService: HealthKitService = HealthKitServiceImpl(),
        foodRecognitionService: FoodRecognitionService = FoodRecognitionServiceImpl()
    ) {
        self.firebaseService = firebaseService
        self.healthKitService = healthKitService
        self.foodRecognitionService = foodRecognitionService
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
    
    // MARK: - Load User Goals
    func loadUserGoals() async {
        // Get user goals from stored onboarding data
        guard let onboardingData = UserDefaults.standard.object(forKey: "onboardingData") as? [String: Any],
              let birthDate = onboardingData["birthDate"] as? Date,
              let sex = onboardingData["sex"] as? String,
              let heightCm = onboardingData["heightCm"] as? Int,
              let weightKg = onboardingData["weightKg"] as? Double,
              let activityLevel = onboardingData["activityLevel"] as? String,
              let target = onboardingData["target"] as? String,
              let weeklyPaceKg = onboardingData["weeklyPaceKg"] as? Double else {
            print("⚠️ [HomeDashboardViewModel] No onboarding data found, using defaults")
            return
        }
        
        // Calculate personalized goals
        let goals = NutritionCalculator.calculateDailyGoals(
            birthDate: birthDate,
            sex: sex,
            heightCm: heightCm,
            weightKg: weightKg,
            activityLevel: activityLevel,
            target: target,
            weeklyPaceKg: weeklyPaceKg
        )
        
        caloriesTarget = goals.calories
        proteinTarget = goals.protein
        carbsTarget = goals.carbs
        fatTarget = goals.fat
        
        print("✅ [HomeDashboardViewModel] Loaded personalized goals: \(goals.calories) cal, \(goals.protein)g protein")
    }
    
    // MARK: - Photo Processing (Cal AI Style)
    func processSelectedPhoto() async {
        guard let photoItem = selectedPhotoItem else { return }
        
        isAnalyzingFood = true
        analysisProgress = 0.0
        
        do {
            // Load image data
            analysisProgress = 0.2
            guard let data = try await photoItem.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                print("❌ [HomeDashboardViewModel] Failed to load image")
                isAnalyzingFood = false
                return
            }
            
            analysisProgress = 0.4
            print("🤖 [HomeDashboardViewModel] Starting AI food recognition...")
            
            // Recognize food
            let result = try await foodRecognitionService.recognise(image: image)
            analysisProgress = 0.8
            
            print("✅ [HomeDashboardViewModel] Food recognized: \(result.name)")
            
            // Create meal automatically
            let meal = Meal(
                id: UUID().uuidString,
                loggedAt: Date(),
                source: "photo",
                name: result.name,
                photoURL: nil,
                calories: result.calories,
                proteinG: result.protein,
                carbsG: result.carbs,
                fatG: result.fat,
                smartSwap: nil
            )
            
            // Save to Firebase
            try await firebaseService.save(meal: meal, for: Date())
            try await firebaseService.updateDayStats(for: Date(), adding: meal)
            
            analysisProgress = 1.0
            print("✅ [HomeDashboardViewModel] Meal saved automatically")
            
            // Wait a moment to show 100%
            try await Task.sleep(nanoseconds: 500_000_000)
            
            // Reload meals and hide analyzing card
            await loadMeals()
            isAnalyzingFood = false
            
        } catch {
            print("❌ [HomeDashboardViewModel] Food processing failed: \(error)")
            isAnalyzingFood = false
            analysisProgress = 0.0
            // TODO: Show error to user
        }
    }
    
    // MARK: - Cleanup
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}