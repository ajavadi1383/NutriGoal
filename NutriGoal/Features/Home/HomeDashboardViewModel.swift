import Foundation
import SwiftUI

@MainActor
final class HomeDashboardViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let firebaseService: FirebaseService
    
    // MARK: - Published Properties
    @Published var meals: [Meal] = []
    @Published var isLoading = false
    
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
            Task { await self?.loadMeals() }
        }
    }
    
    // MARK: - Load Meals
    func loadMeals() async {
        isLoading = true
        
        do {
            meals = try await firebaseService.fetchMeals(for: Date())
            print("✅ [HomeDashboardViewModel] Loaded \(meals.count) meals for today")
        } catch {
            print("❌ [HomeDashboardViewModel] Failed to load meals: \(error)")
            meals = []
        }
        
        isLoading = false
    }
    
    // MARK: - Cleanup
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
} 