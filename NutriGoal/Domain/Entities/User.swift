//
//  User.swift
//  NutriGoal
//
//  Created by Amirali Javadi on 6/7/25.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let email: String
    let createdAt: Date
    
    // Profile Information
    var goal: Goal
    var tone: CoachingTone
    var heightCm: Double
    var weightKg: Double
    var targetWeightKg: Double?
    var activityLevel: ActivityLevel
    var age: Int
    var gender: Gender
    
    // Sleep Preferences
    var bedtime: String // Format: "HH:mm"
    var sleepHours: Double
    
    // Subscription
    var subscriptionStatus: SubscriptionStatus
    
    // Calculated Properties
    var calorieRange: CalorieRange {
        calculateCalorieRange()
    }
    
    var macroTargets: MacroTargets {
        calculateMacroTargets()
    }
    
    init(
        id: String = UUID().uuidString,
        email: String,
        goal: Goal,
        tone: CoachingTone,
        heightCm: Double,
        weightKg: Double,
        targetWeightKg: Double? = nil,
        activityLevel: ActivityLevel,
        bedtime: String,
        sleepHours: Double,
        age: Int,
        gender: Gender,
        subscriptionStatus: SubscriptionStatus = .inactive
    ) {
        self.id = id
        self.email = email
        self.createdAt = Date()
        self.goal = goal
        self.tone = tone
        self.heightCm = heightCm
        self.weightKg = weightKg
        self.targetWeightKg = targetWeightKg
        self.activityLevel = activityLevel
        self.bedtime = bedtime
        self.sleepHours = sleepHours
        self.age = age
        self.gender = gender
        self.subscriptionStatus = subscriptionStatus
    }
}

// MARK: - Supporting Types

enum Goal: String, CaseIterable, Codable {
    case loseWeight = "LoseWeight"
    case maintainWeight = "MaintainWeight"
    case gainMuscle = "GainMuscle"
    
    var displayName: String {
        switch self {
        case .loseWeight:
            return "Lose Weight"
        case .maintainWeight:
            return "Maintain Weight"
        case .gainMuscle:
            return "Gain Muscle"
        }
    }
}

enum CoachingTone: String, CaseIterable, Codable {
    case supportive = "supportive"
    case motivational = "motivational"
    case analytical = "analytical"
    
    var displayName: String {
        switch self {
        case .supportive:
            return "Supportive"
        case .motivational:
            return "Motivational"
        case .analytical:
            return "Analytical"
        }
    }
}

enum ActivityLevel: String, CaseIterable, Codable {
    case sedentary = "sedentary"
    case lightlyActive = "lightly_active"
    case moderatelyActive = "moderately_active"
    case veryActive = "very_active"
    case extremelyActive = "extremely_active"
    
    var displayName: String {
        switch self {
        case .sedentary:
            return "Sedentary"
        case .lightlyActive:
            return "Lightly Active"
        case .moderatelyActive:
            return "Moderately Active"
        case .veryActive:
            return "Very Active"
        case .extremelyActive:
            return "Extremely Active"
        }
    }
    
    var multiplier: Double {
        switch self {
        case .sedentary:
            return 1.2
        case .lightlyActive:
            return 1.375
        case .moderatelyActive:
            return 1.55
        case .veryActive:
            return 1.725
        case .extremelyActive:
            return 1.9
        }
    }
}

enum SubscriptionStatus: String, Codable {
    case active = "active"
    case inactive = "inactive"
    case expired = "expired"
    case cancelled = "cancelled"
}

struct CalorieRange: Codable {
    let min: Double
    let max: Double
    
    func contains(_ calories: Double) -> Bool {
        return calories >= min && calories <= max
    }
}

struct MacroTargets: Codable {
    let proteinGrams: Double
    let carbsGrams: Double
    let fatGrams: Double
    
    // Percentage-based targets
    let proteinPercent: Double
    let carbsPercent: Double
    let fatPercent: Double
}

// MARK: - User Extensions

extension User {
    private func calculateCalorieRange() -> CalorieRange {
        // Calculate BMR using Mifflin-St Jeor Equation
        let bmr: Double
        
        // BMR calculation based on gender
        switch gender {
        case .male:
            bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * Double(age)) + 5
        case .female:
            bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * Double(age)) - 161
        case .other:
            // Use average of male/female formulas
            let maleBMR = (10 * weightKg) + (6.25 * heightCm) - (5 * Double(age)) + 5
            let femaleBMR = (10 * weightKg) + (6.25 * heightCm) - (5 * Double(age)) - 161
            bmr = (maleBMR + femaleBMR) / 2
        }
        
        let tdee = bmr * activityLevel.multiplier
        
        switch goal {
        case .loseWeight:
            let deficit = tdee * 0.2 // 20% deficit
            return CalorieRange(min: deficit - 100, max: deficit + 100)
        case .maintainWeight:
            return CalorieRange(min: tdee - 100, max: tdee + 100)
        case .gainMuscle:
            let surplus = tdee * 1.1 // 10% surplus
            return CalorieRange(min: surplus - 100, max: surplus + 100)
        }
    }
    
    private func calculateMacroTargets() -> MacroTargets {
        let calories = (calorieRange.min + calorieRange.max) / 2
        
        switch goal {
        case .loseWeight:
            // High protein, moderate carbs, moderate fat
            let proteinPercent: Double = 0.30
            let carbsPercent: Double = 0.40
            let fatPercent: Double = 0.30
            
            return MacroTargets(
                proteinGrams: (calories * proteinPercent) / 4, // 4 cal/g protein
                carbsGrams: (calories * carbsPercent) / 4, // 4 cal/g carbs
                fatGrams: (calories * fatPercent) / 9, // 9 cal/g fat
                proteinPercent: proteinPercent,
                carbsPercent: carbsPercent,
                fatPercent: fatPercent
            )
        case .maintainWeight:
            // Balanced macros
            let proteinPercent: Double = 0.25
            let carbsPercent: Double = 0.45
            let fatPercent: Double = 0.30
            
            return MacroTargets(
                proteinGrams: (calories * proteinPercent) / 4,
                carbsGrams: (calories * carbsPercent) / 4,
                fatGrams: (calories * fatPercent) / 9,
                proteinPercent: proteinPercent,
                carbsPercent: carbsPercent,
                fatPercent: fatPercent
            )
        case .gainMuscle:
            // High protein, high carbs, moderate fat
            let proteinPercent: Double = 0.30
            let carbsPercent: Double = 0.50
            let fatPercent: Double = 0.20
            
            return MacroTargets(
                proteinGrams: (calories * proteinPercent) / 4,
                carbsGrams: (calories * carbsPercent) / 4,
                fatGrams: (calories * fatPercent) / 9,
                proteinPercent: proteinPercent,
                carbsPercent: carbsPercent,
                fatPercent: fatPercent
            )
        }
    }
} 