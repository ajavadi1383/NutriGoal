//
//  DIContainer.swift
//  NutriGoal
//
//  Created by Amirali Javadi on 6/7/25.
//

import Foundation
import Combine

// MARK: - Dependency Injection Container

final class DIContainer: ObservableObject {
    static let shared = DIContainer()
    
    private init() {
        setupDependencies()
    }
    
    // MARK: - Repositories
    private(set) var userRepository: UserRepositoryProtocol!
    private(set) var mealRepository: MealRepositoryProtocol!
    private(set) var journalRepository: JournalRepositoryProtocol!
    private(set) var authRepository: AuthenticationRepositoryProtocol!
    private(set) var healthDataRepository: HealthDataRepositoryProtocol!
    private(set) var nutritionAPIRepository: NutritionAPIRepositoryProtocol!
    private(set) var subscriptionRepository: SubscriptionRepositoryProtocol!
    
    // MARK: - Services
    private(set) var aiService: AIServiceProtocol!
    
    // MARK: - Use Cases
    private(set) var authenticationUseCase: AuthenticationUseCaseProtocol!
    private(set) var userProfileUseCase: UserProfileUseCaseProtocol!
    private(set) var mealLoggingUseCase: MealLoggingUseCaseProtocol!
    private(set) var journalGenerationUseCase: JournalGenerationUseCaseProtocol!
    private(set) var lifestyleScoreUseCase: LifestyleScoreUseCaseProtocol!
    private(set) var aiCoachUseCase: AICoachUseCaseProtocol!
    private(set) var healthDataUseCase: HealthDataUseCaseProtocol!
    private(set) var subscriptionUseCase: SubscriptionUseCaseProtocol!
    
    // MARK: - Setup Dependencies
    
    private func setupDependencies() {
        setupRepositories()
        setupServices()
        setupUseCases()
    }
    
    private func setupRepositories() {
        // In development, we'll use mock implementations
        // In production, these will be real Firebase/API implementations
        
        #if DEBUG
        if AppConfiguration.Environment.current == .development {
            userRepository = MockUserRepository()
            mealRepository = MockMealRepository()
            journalRepository = MockJournalRepository()
            authRepository = MockAuthenticationRepository()
            healthDataRepository = MockHealthDataRepository()
            nutritionAPIRepository = MockNutritionAPIRepository()
            subscriptionRepository = MockSubscriptionRepository()
        } else {
            setupProductionRepositories()
        }
        #else
        setupProductionRepositories()
        #endif
    }
    
    private func setupProductionRepositories() {
        // TODO: Implement production repositories
        // authRepository = FirebaseAuthRepository()
        // userRepository = FirestoreUserRepository()
        // mealRepository = FirestoreMealRepository()
        // journalRepository = FirestoreJournalRepository()
        // healthDataRepository = HealthKitRepository()
        // nutritionAPIRepository = OpenFoodFactsRepository()
        // subscriptionRepository = RevenueCatRepository()
        
        // For now, use mocks even in production until we implement real ones
        userRepository = MockUserRepository()
        mealRepository = MockMealRepository()
        journalRepository = MockJournalRepository()
        authRepository = MockAuthenticationRepository()
        healthDataRepository = MockHealthDataRepository()
        nutritionAPIRepository = MockNutritionAPIRepository()
        subscriptionRepository = MockSubscriptionRepository()
    }
    
    private func setupServices() {
        // TODO: Implement production AI service
        // aiService = OpenAIService()
        
        // For now, use mock
        aiService = MockAIService()
    }
    
    private func setupUseCases() {
        authenticationUseCase = AuthenticationUseCase(
            authRepository: authRepository,
            userRepository: userRepository
        )
        
        userProfileUseCase = UserProfileUseCase(
            userRepository: userRepository
        )
        
        mealLoggingUseCase = MealLoggingUseCase(
            mealRepository: mealRepository,
            nutritionAPIRepository: nutritionAPIRepository,
            aiService: aiService
        )
        
        journalGenerationUseCase = JournalGenerationUseCase(
            journalRepository: journalRepository,
            mealRepository: mealRepository,
            healthDataRepository: healthDataRepository,
            aiService: aiService
        )
        
        lifestyleScoreUseCase = LifestyleScoreUseCase(
            mealRepository: mealRepository,
            healthDataRepository: healthDataRepository,
            userRepository: userRepository
        )
        
        aiCoachUseCase = AICoachUseCase(
            aiService: aiService,
            userRepository: userRepository
        )
        
        healthDataUseCase = HealthDataUseCase(
            healthDataRepository: healthDataRepository
        )
        
        subscriptionUseCase = SubscriptionUseCase(
            subscriptionRepository: subscriptionRepository,
            userRepository: userRepository
        )
    }
}

// MARK: - Use Case Protocols

protocol AuthenticationUseCaseProtocol {
    func signUp(email: String, password: String) async throws -> AuthResult
    func signIn(email: String, password: String) async throws -> AuthResult
    func signInWithApple() async throws -> AuthResult
    func signOut() async throws
    func getCurrentUser() async throws -> User?
    func isUserLoggedIn() -> Bool
}

protocol UserProfileUseCaseProtocol {
    func updateUserProfile(_ user: User) async throws -> User
    func getUserProfile() async throws -> User?
    func calculateUserGoals(_ user: User) -> (CalorieRange, MacroTargets)
}

protocol MealLoggingUseCaseProtocol {
    func logMeal(_ meal: Meal) async throws -> Meal
    func getMealsForToday() async throws -> [Meal]
    func searchFood(query: String) async throws -> [FoodItem]
    func recognizeFoodFromPhoto(_ imageData: Data) async throws -> FoodRecognitionResult
    func scanBarcode(_ barcode: String) async throws -> FoodItem?
}

protocol JournalGenerationUseCaseProtocol {
    func generateTodaysJournal() async throws -> JournalEntry
    func getJournalHistory(limit: Int?) async throws -> [JournalEntry]
    func getJournalForDate(_ date: String) async throws -> JournalEntry?
}

protocol LifestyleScoreUseCaseProtocol {
    func calculateTodaysScore() async throws -> LifestyleScore
    func getScoreHistory(days: Int) async throws -> [LifestyleScore]
    func getScoreComponents() async throws -> ScoreComponents
}

protocol AICoachUseCaseProtocol {
    func sendMessage(_ message: String) async throws -> String
    func getConversationHistory() async throws -> [ChatMessage]
    func clearConversation() async throws
}

protocol HealthDataUseCaseProtocol {
    func requestPermissions() async throws -> Bool
    func getTodaysHealthData() async throws -> DailyHealthData
    func syncHealthData() async throws
}

protocol SubscriptionUseCaseProtocol {
    func getSubscriptionStatus() async throws -> SubscriptionStatus
    func purchaseSubscription(_ product: SubscriptionProduct) async throws -> PurchaseResult
    func restorePurchases() async throws
    func getAvailableProducts() async throws -> [SubscriptionProduct]
}

// MARK: - Supporting Types

struct DailyHealthData {
    let steps: Int
    let sleepData: SleepData?
    let workouts: [WorkoutData]
    let heartRate: Double?
    let bodyWeight: Double?
}

// MARK: - Mock Implementations (Temporary)

// These are temporary mock implementations for development
// They will be replaced with real implementations in later phases

class MockUserRepository: UserRepositoryProtocol {
    func createUser(_ user: User) async throws -> User { user }
    func getUser(id: String) async throws -> User? { nil }
    func getCurrentUser() async throws -> User? { nil }
    func updateUser(_ user: User) async throws -> User { user }
    func deleteUser(id: String) async throws {}
    func getCurrentUserId() -> String? { nil }
    func isUserLoggedIn() -> Bool { false }
}

class MockMealRepository: MealRepositoryProtocol {
    func createMeal(_ meal: Meal) async throws -> Meal { meal }
    func getMeal(id: String) async throws -> Meal? { nil }
    func getMealsForDate(userId: String, date: String) async throws -> [Meal] { [] }
    func getMealsForDateRange(userId: String, startDate: String, endDate: String) async throws -> [Meal] { [] }
    func updateMeal(_ meal: Meal) async throws -> Meal { meal }
    func deleteMeal(id: String) async throws {}
    func getDailyMealSummary(userId: String, date: String) async throws -> DailyMealSummary {
        DailyMealSummary(date: date, meals: [])
    }
    func mealsForDatePublisher(userId: String, date: String) -> AnyPublisher<[Meal], Error> {
        Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

class MockJournalRepository: JournalRepositoryProtocol {
    func createJournalEntry(_ entry: JournalEntry) async throws -> JournalEntry { entry }
    func getJournalEntry(userId: String, date: String) async throws -> JournalEntry? { nil }
    func getJournalEntries(userId: String, limit: Int?) async throws -> [JournalEntry] { [] }
    func updateJournalEntry(_ entry: JournalEntry) async throws -> JournalEntry { entry }
    func deleteJournalEntry(userId: String, date: String) async throws {}
    func journalEntriesPublisher(userId: String) -> AnyPublisher<[JournalEntry], Error> {
        Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

class MockAuthenticationRepository: AuthenticationRepositoryProtocol {
    func signUp(email: String, password: String) async throws -> AuthResult {
        AuthResult(userId: "mock", email: email, isNewUser: true, token: "mock-token")
    }
    func signIn(email: String, password: String) async throws -> AuthResult {
        AuthResult(userId: "mock", email: email, isNewUser: false, token: "mock-token")
    }
    func signInWithGoogle() async throws -> AuthResult {
        AuthResult(userId: "mock", email: "mock@google.com", isNewUser: false, token: "mock-token")
    }
    func signInWithApple() async throws -> AuthResult {
        AuthResult(userId: "mock", email: "mock@apple.com", isNewUser: false, token: "mock-token")
    }
    func signInWithFacebook() async throws -> AuthResult {
        AuthResult(userId: "mock", email: "mock@facebook.com", isNewUser: false, token: "mock-token")
    }
    func signOut() async throws {}
    func resetPassword(email: String) async throws {}
    func deleteAccount() async throws {}
    func getCurrentAuthToken() async throws -> String? { "mock-token" }
    func refreshToken() async throws -> String { "mock-token" }
    func authStatePublisher() -> AnyPublisher<AuthState, Never> {
        Just(.unauthenticated).eraseToAnyPublisher()
    }
}

class MockHealthDataRepository: HealthDataRepositoryProtocol {
    func requestHealthKitPermissions() async throws -> Bool { true }
    func isHealthKitAvailable() -> Bool { true }
    func getStepsForDate(_ date: Date) async throws -> Int { 8000 }
    func getSleepDataForDate(_ date: Date) async throws -> SleepData {
        SleepData(duration: 7.5, bedtime: "23:00", wakeTime: "06:30", quality: .good)
    }
    func getWorkoutDataForDate(_ date: Date) async throws -> [WorkoutData] { [] }
    func getHeartRateForDate(_ date: Date) async throws -> Double? { 70.0 }
    func getBodyWeightForDate(_ date: Date) async throws -> Double? { 70.0 }
    func saveBodyWeight(_ weight: Double, date: Date) async throws {}
    func stepsPublisher(for date: Date) -> AnyPublisher<Int, Error> {
        Just(8000).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    func sleepDataPublisher(for date: Date) -> AnyPublisher<SleepData, Error> {
        let sleepData = SleepData(duration: 7.5, bedtime: "23:00", wakeTime: "06:30", quality: .good)
        return Just(sleepData).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

class MockNutritionAPIRepository: NutritionAPIRepositoryProtocol {
    func searchFood(query: String) async throws -> [FoodItem] { [] }
    func getFoodByBarcode(_ barcode: String) async throws -> FoodItem? { nil }
    func getFoodDetails(id: String) async throws -> FoodItem? { nil }
    func getPopularFoods(category: FoodCategory?) async throws -> [FoodItem] { [] }
    func getFoodSuggestions(query: String) async throws -> [String] { [] }
}

class MockSubscriptionRepository: SubscriptionRepositoryProtocol {
    func getAvailableProducts() async throws -> [SubscriptionProduct] { [] }
    func purchaseProduct(_ product: SubscriptionProduct) async throws -> PurchaseResult {
        PurchaseResult(productId: product.id, transactionId: "mock", purchaseDate: Date(), expiryDate: nil)
    }
    func restorePurchases() async throws -> [PurchaseResult] { [] }
    func getSubscriptionStatus() async throws -> SubscriptionStatus { .inactive }
    func validateReceipt() async throws -> Bool { true }
    func checkSubscriptionExpiry() async throws -> Date? { nil }
    func subscriptionStatusPublisher() -> AnyPublisher<SubscriptionStatus, Never> {
        Just(.inactive).eraseToAnyPublisher()
    }
}

class MockAIService: AIServiceProtocol {
    func generateJournal(user: User, dailyData: DailyAIData) async throws -> String {
        "This is a mock journal entry for development."
    }
    func getChatResponse(user: User, message: String, conversationHistory: [ChatMessage]) async throws -> String {
        "This is a mock AI response."
    }
    func recognizeFood(imageData: Data) async throws -> FoodRecognitionResult {
        FoodRecognitionResult(detectedFoods: [], confidence: 0.5)
    }
    func generateJournalPrompt(user: User, dailyData: DailyAIData) -> String {
        "Mock journal prompt"
    }
    func generateChatPrompt(user: User, conversationHistory: [ChatMessage]) -> String {
        "Mock chat prompt"
    }
} 