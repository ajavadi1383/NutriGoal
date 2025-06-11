//
//  UserRepository.swift
//  NutriGoal
//
//  Created by Amirali Javadi on 6/7/25.
//

import Foundation
import Combine

// MARK: - User Repository Protocol

protocol UserRepositoryProtocol {
    // User CRUD operations
    func createUser(_ user: User) async throws -> User
    func getUser(id: String) async throws -> User?
    func getCurrentUser() async throws -> User?
    func updateUser(_ user: User) async throws -> User
    func deleteUser(id: String) async throws
    
    // User session management
    func getCurrentUserId() -> String?
    func isUserLoggedIn() -> Bool
}

// MARK: - Meal Repository Protocol

protocol MealRepositoryProtocol {
    // Meal CRUD operations
    func createMeal(_ meal: Meal) async throws -> Meal
    func getMeal(id: String) async throws -> Meal?
    func getMealsForDate(userId: String, date: String) async throws -> [Meal]
    func getMealsForDateRange(userId: String, startDate: String, endDate: String) async throws -> [Meal]
    func updateMeal(_ meal: Meal) async throws -> Meal
    func deleteMeal(id: String) async throws
    
    // Daily meal summary
    func getDailyMealSummary(userId: String, date: String) async throws -> DailyMealSummary
    
    // Reactive streams
    func mealsForDatePublisher(userId: String, date: String) -> AnyPublisher<[Meal], Error>
}

// MARK: - Journal Repository Protocol

protocol JournalRepositoryProtocol {
    // Journal CRUD operations
    func createJournalEntry(_ entry: JournalEntry) async throws -> JournalEntry
    func getJournalEntry(userId: String, date: String) async throws -> JournalEntry?
    func getJournalEntries(userId: String, limit: Int?) async throws -> [JournalEntry]
    func updateJournalEntry(_ entry: JournalEntry) async throws -> JournalEntry
    func deleteJournalEntry(userId: String, date: String) async throws
    
    // Reactive streams
    func journalEntriesPublisher(userId: String) -> AnyPublisher<[JournalEntry], Error>
}

// MARK: - Authentication Repository Protocol

protocol AuthenticationRepositoryProtocol {
    // Authentication operations
    func signUp(email: String, password: String) async throws -> AuthResult
    func signIn(email: String, password: String) async throws -> AuthResult
    func signInWithGoogle() async throws -> AuthResult
    func signInWithApple() async throws -> AuthResult
    func signInWithFacebook() async throws -> AuthResult
    func signOut() async throws
    func resetPassword(email: String) async throws
    func deleteAccount() async throws
    
    // Authentication state
    func getCurrentAuthToken() async throws -> String?
    func refreshToken() async throws -> String
    
    // Reactive authentication state
    func authStatePublisher() -> AnyPublisher<AuthState, Never>
}

// MARK: - Health Data Repository Protocol

protocol HealthDataRepositoryProtocol {
    // HealthKit permissions
    func requestHealthKitPermissions() async throws -> Bool
    func isHealthKitAvailable() -> Bool
    
    // Reading health data
    func getStepsForDate(_ date: Date) async throws -> Int
    func getSleepDataForDate(_ date: Date) async throws -> SleepData
    func getWorkoutDataForDate(_ date: Date) async throws -> [WorkoutData]
    func getHeartRateForDate(_ date: Date) async throws -> Double?
    func getBodyWeightForDate(_ date: Date) async throws -> Double?
    
    // Writing health data
    func saveBodyWeight(_ weight: Double, date: Date) async throws
    
    // Reactive health data streams
    func stepsPublisher(for date: Date) -> AnyPublisher<Int, Error>
    func sleepDataPublisher(for date: Date) -> AnyPublisher<SleepData, Error>
}

// MARK: - AI Service Protocol

protocol AIServiceProtocol {
    // Journal generation
    func generateJournal(
        user: User,
        dailyData: DailyAIData
    ) async throws -> String
    
    // Chat coaching
    func getChatResponse(
        user: User,
        message: String,
        conversationHistory: [ChatMessage]
    ) async throws -> String
    
    // Food recognition
    func recognizeFood(imageData: Data) async throws -> FoodRecognitionResult
    
    // Prompt generation
    func generateJournalPrompt(user: User, dailyData: DailyAIData) -> String
    func generateChatPrompt(user: User, conversationHistory: [ChatMessage]) -> String
}

// MARK: - Nutrition API Repository Protocol

protocol NutritionAPIRepositoryProtocol {
    // Food search
    func searchFood(query: String) async throws -> [FoodItem]
    func getFoodByBarcode(_ barcode: String) async throws -> FoodItem?
    func getFoodDetails(id: String) async throws -> FoodItem?
    
    // Food database
    func getPopularFoods(category: FoodCategory?) async throws -> [FoodItem]
    func getFoodSuggestions(query: String) async throws -> [String]
}

// MARK: - Subscription Repository Protocol

protocol SubscriptionRepositoryProtocol {
    // Subscription management
    func getAvailableProducts() async throws -> [SubscriptionProduct]
    func purchaseProduct(_ product: SubscriptionProduct) async throws -> PurchaseResult
    func restorePurchases() async throws -> [PurchaseResult]
    func getSubscriptionStatus() async throws -> SubscriptionStatus
    
    // Subscription validation
    func validateReceipt() async throws -> Bool
    func checkSubscriptionExpiry() async throws -> Date?
    
    // Reactive subscription state
    func subscriptionStatusPublisher() -> AnyPublisher<SubscriptionStatus, Never>
}

// MARK: - Supporting Types

struct AuthResult {
    let userId: String
    let email: String
    let isNewUser: Bool
    let token: String
}

enum AuthState {
    case authenticated(User)
    case unauthenticated
    case loading
}

struct SleepData {
    let duration: Double // in hours
    let bedtime: String // "HH:mm" format
    let wakeTime: String // "HH:mm" format
    let quality: SleepQuality?
}

enum SleepQuality: String, CaseIterable {
    case poor = "poor"
    case fair = "fair"
    case good = "good"
    case excellent = "excellent"
}

struct WorkoutData {
    let type: WorkoutType
    let duration: Double // in minutes
    let caloriesBurned: Double?
    let startTime: Date
    let endTime: Date
}

enum WorkoutType: String, CaseIterable {
    case walking = "walking"
    case running = "running"
    case cycling = "cycling"
    case swimming = "swimming"
    case strength = "strength"
    case yoga = "yoga"
    case other = "other"
}

struct DailyAIData {
    let date: String
    let score: Double
    let calories: Double
    let macros: (protein: Double, carbs: Double, fat: Double)
    let steps: Int
    let workoutMinutes: Double
    let sleepHours: Double
    let bedtime: String
    let waterLiters: Double
    let mood: String?
}

struct ChatMessage {
    let id: String
    let content: String
    let isFromUser: Bool
    let timestamp: Date
}

struct FoodRecognitionResult {
    let detectedFoods: [DetectedFood]
    let confidence: Double
}

struct DetectedFood {
    let name: String
    let confidence: Double
    let estimatedCalories: Double?
    let estimatedWeight: Double?
}

struct FoodItem {
    let id: String
    let name: String
    let brand: String?
    let barcode: String?
    let servingSize: String
    let nutrition: NutritionInfo
}

struct NutritionInfo {
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double?
    let sugar: Double?
    let sodium: Double?
}

enum FoodCategory: String, CaseIterable {
    case fruits = "fruits"
    case vegetables = "vegetables"
    case grains = "grains"
    case proteins = "proteins"
    case dairy = "dairy"
    case snacks = "snacks"
    case beverages = "beverages"
}

struct SubscriptionProduct {
    let id: String
    let title: String
    let description: String
    let price: String
    let duration: SubscriptionDuration
}

enum SubscriptionDuration {
    case monthly
    case yearly
}

struct PurchaseResult {
    let productId: String
    let transactionId: String
    let purchaseDate: Date
    let expiryDate: Date?
} 