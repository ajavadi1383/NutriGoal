import Foundation
import SwiftUI

@MainActor
final class HomeDashboardViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let firebaseService: FirebaseService
    
    // MARK: - Published Properties
    @Published var meals: [Meal] = []
    @Published var isLoading = false
    @Published var selectedDate = Date()
    
    // Daily stats
    @Published var caloriesConsumed = 1450
    @Published var caloriesTarget = 2100
    @Published var steps = 9845
    @Published var stepsTarget = 10000
    @Published var caloriesBurned = 332
    @Published var waterOunces = 24
    
    // MARK: - Init
    init(firebaseService: FirebaseService = FirebaseServiceImpl()) {
        self.firebaseService = firebaseService
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
                await self?.updateDailyStats()
            }
        }
    }
    
    // MARK: - Load Data
    func loadMeals() async {
        isLoading = true
        
        do {
            meals = try await firebaseService.fetchMeals(for: selectedDate)
            print("✅ [HomeDashboardViewModel] Loaded \(meals.count) meals for today")
        } catch {
            print("❌ [HomeDashboardViewModel] Failed to load meals: \(error)")
            meals = []
        }
        
        isLoading = false
    }
    
    func updateDailyStats() async {
        // Calculate calories from meals
        let totalCalories = meals.reduce(0) { $0 + $1.calories }
        caloriesConsumed = totalCalories
        
        print("📊 [HomeDashboardViewModel] Updated daily stats: \(totalCalories) calories from \(meals.count) meals")
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