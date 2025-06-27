//
//  AllUseCases.swift
//  NutriGoal
//
//  Created by Amirali Javadi on 6/7/25.
//

import Foundation

// MARK: - Meal Logging Use Case

final class MealLoggingUseCase: MealLoggingUseCaseProtocol {
    private let mealRepository: MealRepositoryProtocol
    private let nutritionAPIRepository: NutritionAPIRepositoryProtocol
    private let aiService: AIServiceProtocol
    
    init(
        mealRepository: MealRepositoryProtocol,
        nutritionAPIRepository: NutritionAPIRepositoryProtocol,
        aiService: AIServiceProtocol
    ) {
        self.mealRepository = mealRepository
        self.nutritionAPIRepository = nutritionAPIRepository
        self.aiService = aiService
    }
    
    func logMeal(_ meal: Meal) async throws -> Meal {
        return try await mealRepository.createMeal(meal)
    }
    
    func getMealsForToday() async throws -> [Meal] {
        let today = DateFormatter.dateString(from: Date())
        // For now, return empty array - will need user ID
        return []
    }
    
    func searchFood(query: String) async throws -> [FoodItem] {
        return try await nutritionAPIRepository.searchFood(query: query)
    }
    
    func recognizeFoodFromPhoto(_ imageData: Data) async throws -> FoodRecognitionResult {
        return try await aiService.recognizeFood(imageData: imageData)
    }
    
    func scanBarcode(_ barcode: String) async throws -> FoodItem? {
        return try await nutritionAPIRepository.getFoodByBarcode(barcode)
    }
}

// MARK: - Journal Generation Use Case

final class JournalGenerationUseCase: JournalGenerationUseCaseProtocol {
    private let journalRepository: JournalRepositoryProtocol
    private let mealRepository: MealRepositoryProtocol
    private let healthDataRepository: HealthDataRepositoryProtocol
    private let aiService: AIServiceProtocol
    
    init(
        journalRepository: JournalRepositoryProtocol,
        mealRepository: MealRepositoryProtocol,
        healthDataRepository: HealthDataRepositoryProtocol,
        aiService: AIServiceProtocol
    ) {
        self.journalRepository = journalRepository
        self.mealRepository = mealRepository
        self.healthDataRepository = healthDataRepository
        self.aiService = aiService
    }
    
    func generateTodaysJournal() async throws -> JournalEntry {
        // TODO: Implement actual journal generation logic
        let today = DateFormatter.dateString(from: Date())
        let mockEntry = JournalEntry(
            userId: "mock",
            date: today,
            entryText: "Mock journal entry",
            score: 8.0,
            calories: 2000,
            proteinGrams: 120,
            carbsGrams: 200,
            fatGrams: 80,
            steps: 8000,
            workoutMinutes: 30,
            sleepHours: 7.5,
            bedtime: "23:00",
            waterLiters: 2.0,
            tone: .supportive
        )
        return try await journalRepository.createJournalEntry(mockEntry)
    }
    
    func getJournalHistory(limit: Int?) async throws -> [JournalEntry] {
        return try await journalRepository.getJournalEntries(userId: "mock", limit: limit)
    }
    
    func getJournalForDate(_ date: String) async throws -> JournalEntry? {
        return try await journalRepository.getJournalEntry(userId: "mock", date: date)
    }
}

// MARK: - Lifestyle Score Use Case

final class LifestyleScoreUseCase: LifestyleScoreUseCaseProtocol {
    private let mealRepository: MealRepositoryProtocol
    private let healthDataRepository: HealthDataRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    
    init(
        mealRepository: MealRepositoryProtocol,
        healthDataRepository: HealthDataRepositoryProtocol,
        userRepository: UserRepositoryProtocol
    ) {
        self.mealRepository = mealRepository
        self.healthDataRepository = healthDataRepository
        self.userRepository = userRepository
    }
    
    func calculateTodaysScore() async throws -> LifestyleScore {
        // TODO: Implement actual score calculation
        let components = ScoreComponents(
            calorieAdherence: 8.0,
            macroBalance: 7.5,
            stepsScore: 9.0,
            workoutScore: 6.0,
            sleepDuration: 8.5,
            bedtimeConsistency: 7.0,
            hydrationScore: 8.0
        )
        return LifestyleScore(date: DateFormatter.dateString(from: Date()), components: components)
    }
    
    func getScoreHistory(days: Int) async throws -> [LifestyleScore] {
        return []
    }
    
    func getScoreComponents() async throws -> ScoreComponents {
        return ScoreComponents(
            calorieAdherence: 8.0,
            macroBalance: 7.5,
            stepsScore: 9.0,
            workoutScore: 6.0,
            sleepDuration: 8.5,
            bedtimeConsistency: 7.0,
            hydrationScore: 8.0
        )
    }
}

// MARK: - AI Coach Use Case

final class AICoachUseCase: AICoachUseCaseProtocol {
    private let aiService: AIServiceProtocol
    private let userRepository: UserRepositoryProtocol
    
    init(
        aiService: AIServiceProtocol,
        userRepository: UserRepositoryProtocol
    ) {
        self.aiService = aiService
        self.userRepository = userRepository
    }
    
    func sendMessage(_ message: String) async throws -> String {
        // TODO: Implement actual chat logic with conversation history
        guard let user = try await userRepository.getCurrentUser() else {
            throw NSError(domain: "AICoachUseCase", code: 1, userInfo: [NSLocalizedDescriptionKey: "No user found"])
        }
        return try await aiService.getChatResponse(user: user, message: message, conversationHistory: [])
    }
    
    func getConversationHistory() async throws -> [ChatMessage] {
        return []
    }
    
    func clearConversation() async throws {
        // TODO: Implement conversation clearing
    }
}

// MARK: - Health Data Use Case

final class HealthDataUseCase: HealthDataUseCaseProtocol {
    private let healthDataRepository: HealthDataRepositoryProtocol
    
    init(healthDataRepository: HealthDataRepositoryProtocol) {
        self.healthDataRepository = healthDataRepository
    }
    
    func requestPermissions() async throws -> Bool {
        return try await healthDataRepository.requestHealthKitPermissions()
    }
    
    func getTodaysHealthData() async throws -> DailyHealthData {
        let today = Date()
        let steps = try await healthDataRepository.getStepsForDate(today)
        let sleepData = try? await healthDataRepository.getSleepDataForDate(today)
        let workouts = try await healthDataRepository.getWorkoutDataForDate(today)
        let heartRate = try? await healthDataRepository.getHeartRateForDate(today)
        let bodyWeight = try? await healthDataRepository.getBodyWeightForDate(today)
        
        return DailyHealthData(
            steps: steps,
            sleepData: sleepData,
            workouts: workouts,
            heartRate: heartRate,
            bodyWeight: bodyWeight
        )
    }
    
    func syncHealthData() async throws {
        // TODO: Implement health data sync logic
    }
}

// MARK: - Subscription Use Case

final class SubscriptionUseCase: SubscriptionUseCaseProtocol {
    private let subscriptionRepository: SubscriptionRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    
    init(
        subscriptionRepository: SubscriptionRepositoryProtocol,
        userRepository: UserRepositoryProtocol
    ) {
        self.subscriptionRepository = subscriptionRepository
        self.userRepository = userRepository
    }
    
    func getSubscriptionStatus() async throws -> SubscriptionStatus {
        return try await subscriptionRepository.getSubscriptionStatus()
    }
    
    func purchaseSubscription(_ product: SubscriptionProduct) async throws -> PurchaseResult {
        let result = try await subscriptionRepository.purchaseProduct(product)
        
        // Update user subscription status
        if var user = try await userRepository.getCurrentUser() {
            user.subscriptionStatus = .active
            _ = try await userRepository.updateUser(user)
        }
        
        return result
    }
    
    func restorePurchases() async throws {
        _ = try await subscriptionRepository.restorePurchases()
    }
    
    func getAvailableProducts() async throws -> [SubscriptionProduct] {
        return try await subscriptionRepository.getAvailableProducts()
    }
} 