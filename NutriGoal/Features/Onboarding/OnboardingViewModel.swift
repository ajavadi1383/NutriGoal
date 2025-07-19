import Foundation
import SwiftUI

// TODO: Define FirebaseService protocol
protocol FirebaseService {
    func save(profile: UserProfile) async throws
}

@MainActor
final class OnboardingViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let authManager: AuthManager
    private let firebaseService: FirebaseService?
    
    // MARK: - Published Properties
    @Published var currentStep = 0
    @Published var birthDate = Date.now.addingTimeInterval(-25 * 365 * 24 * 60 * 60) // Default: 25 years old
    @Published var sex = "male"
    @Published var heightCm = 170
    @Published var weightKg = 70.0
    @Published var activityLevel = "3-4"
    @Published var target = "maintain"
    @Published var weeklyPaceKg = 0.5
    @Published var dietType = "none"
    @Published var onboardingComplete = false
    
    // MARK: - Computed Properties
    var canProceed: Bool {
        switch currentStep {
        case 0: return true // birthDate always valid
        case 1: return !sex.isEmpty
        case 2: return heightCm > 0
        case 3: return weightKg > 0
        case 4: return !activityLevel.isEmpty
        case 5: return !target.isEmpty
        case 6: return weeklyPaceKg >= 0
        case 7: return !dietType.isEmpty
        default: return false
        }
    }
    
    private var age: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date.now).year ?? 25
    }
    
    // MARK: - Init
    init(authManager: AuthManager, firebaseService: FirebaseService?) {
        self.authManager = authManager
        self.firebaseService = firebaseService
    }
    
    // MARK: - Actions
    func nextStep() {
        withAnimation {
            currentStep = min(currentStep + 1, 7)
        }
    }
    
    func finishOnboarding() async {
        guard let uid = authManager.currentUID else { return }
        
        // 1. Calculate BMR using Mifflin-St Jeor equation
        let bmr = calculateBMR()
        
        // 2. Calculate TDEE
        let tdee = calculateTDEE(bmr: bmr)
        
        // 3. Calculate macro ranges (simplified constants for now)
        let (proteinG, carbsG, fatG) = calculateMacros(tdee: tdee)
        
        // 4. Build UserProfile
        let profile = UserProfile(
            id: uid,
            email: "anonymous@nutrigoal.app", // TODO: Get actual email when auth is expanded
            birthDate: birthDate,
            sex: sex,
            heightCm: heightCm,
            weightKg: weightKg,
            activityLevel: activityLevel,
            target: target,
            weeklyPaceKg: weeklyPaceKg,
            goalDate: Calendar.current.date(byAdding: .month, value: 3, to: Date.now) ?? Date.now,
            dietType: dietType,
            lang: "en", // TODO: Get from system locale
            createdAt: Date.now
        )
        
        // 5. Save profile to Firebase
        do {
            try await firebaseService?.save(profile: profile)
            onboardingComplete = true
        } catch {
            // TODO: Show error to user
            print("Failed to save profile: \(error)")
        }
    }
    
    // MARK: - Nutrition Calculations
    
    private func calculateBMR() -> Double {
        // Mifflin-St Jeor equation
        let baseBMR = 10 * weightKg + 6.25 * Double(heightCm) - 5 * Double(age)
        return sex == "male" ? baseBMR + 5 : baseBMR - 161
    }
    
    private func calculateTDEE(bmr: Double) -> Double {
        let activityMultiplier: Double = switch activityLevel {
        case "1-2": 1.2
        case "3-4": 1.375
        case "5-6": 1.55
        default: 1.2
        }
        return bmr * activityMultiplier
    }
    
    private func calculateMacros(tdee: Double) -> (protein: Int, carbs: Int, fat: Int) {
        // Simplified macro calculation (TODO: refine based on target)
        let proteinCalsPerGram = 4.0
        let carbCalsPerGram = 4.0
        let fatCalsPerGram = 9.0
        
        // Basic ratios - TODO: adjust based on target
        let proteinRatio = 0.25 // 25% protein
        let fatRatio = 0.30     // 30% fat
        let carbRatio = 0.45    // 45% carbs
        
        let proteinG = Int((tdee * proteinRatio) / proteinCalsPerGram)
        let fatG = Int((tdee * fatRatio) / fatCalsPerGram)
        let carbsG = Int((tdee * carbRatio) / carbCalsPerGram)
        
        return (proteinG, carbsG, fatG)
    }
} 