//
//  OnboardingData.swift
//  NutriGoal
//
//  Created by Amirali Javadi on 6/7/25.
//

import Foundation

struct OnboardingData {
    // Personal Information
    var age: Int?
    var gender: Gender?
    var heightCm: Double?
    var weightKg: Double?
    var targetWeightKg: Double?
    
    // Goals & Preferences
    var goal: Goal?
    var activityLevel: ActivityLevel?
    var targetTimeline: TargetTimeline?
    var tone: CoachingTone?
    
    // Sleep Information
    var bedtime: String?
    var sleepHours: Double?
    
    // Email (from auth)
    var email: String?
    
    var isComplete: Bool {
        return age != nil &&
               gender != nil &&
               heightCm != nil &&
               weightKg != nil &&
               goal != nil &&
               activityLevel != nil &&
               targetTimeline != nil &&
               tone != nil &&
               bedtime != nil &&
               sleepHours != nil &&
               email != nil
    }
    
    func toUser() -> User {
        return User(
            email: email ?? "",
            goal: goal ?? .loseWeight,
            tone: tone ?? .supportive,
            heightCm: heightCm ?? 170,
            weightKg: weightKg ?? 70,
            targetWeightKg: targetWeightKg,
            activityLevel: activityLevel ?? .moderatelyActive,
            bedtime: bedtime ?? "23:00",
            sleepHours: sleepHours ?? 7.0,
            age: age ?? 25,
            gender: gender ?? .other
        )
    }
}

// MARK: - Supporting Enums

enum Gender: String, CaseIterable, Codable {
    case male = "male"
    case female = "female"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .male:
            return "Male"
        case .female:
            return "Female"
        case .other:
            return "Other"
        }
    }
}

enum TargetTimeline: String, CaseIterable, Codable {
    case slow = "slow"           // 0.5-1 lb/week
    case moderate = "moderate"   // 1-1.5 lb/week  
    case fast = "fast"           // 1.5-2 lb/week
    case maintain = "maintain"   // For maintenance goals
    
    var displayName: String {
        switch self {
        case .slow:
            return "Slow & Steady (0.5-1 lb/week)"
        case .moderate:
            return "Moderate (1-1.5 lb/week)"
        case .fast:
            return "Fast (1.5-2 lb/week)"
        case .maintain:
            return "Maintain Current Weight"
        }
    }
    
    var description: String {
        switch self {
        case .slow:
            return "Sustainable and easy to maintain"
        case .moderate:
            return "Balanced approach with good results"
        case .fast:
            return "Aggressive but achievable"
        case .maintain:
            return "Focus on healthy habits"
        }
    }
    
    var multiplier: Double {
        switch self {
        case .slow:
            return 0.9    // 10% deficit
        case .moderate:
            return 0.85   // 15% deficit
        case .fast:
            return 0.8    // 20% deficit
        case .maintain:
            return 1.0    // Maintenance
        }
    }
} 