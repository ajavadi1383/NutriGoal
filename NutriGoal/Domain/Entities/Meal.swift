//
//  Meal.swift
//  NutriGoal
//
//  Created by Amirali Javadi on 6/7/25.
//

import Foundation

struct Meal: Identifiable, Codable {
    let id: String
    let userId: String
    let date: String // Format: "YYYY-MM-DD"
    let timestamp: Date
    
    // Basic Information
    var name: String
    var photoURL: String?
    
    // Nutrition Information
    var calories: Double
    var proteinGrams: Double
    var carbsGrams: Double
    var fatGrams: Double
    
    // Optional detailed nutrients
    var fiberGrams: Double?
    var sugarGrams: Double?
    var sodiumMg: Double?
    
    // Meal metadata
    var mealType: MealType
    var servingSize: String?
    var brand: String?
    var barcode: String?
    
    // AI Recognition data
    var recognitionConfidence: Double?
    var isAIGenerated: Bool
    var isVerified: Bool
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        date: String,
        name: String,
        calories: Double,
        proteinGrams: Double,
        carbsGrams: Double,
        fatGrams: Double,
        mealType: MealType,
        photoURL: String? = nil,
        fiberGrams: Double? = nil,
        sugarGrams: Double? = nil,
        sodiumMg: Double? = nil,
        servingSize: String? = nil,
        brand: String? = nil,
        barcode: String? = nil,
        recognitionConfidence: Double? = nil,
        isAIGenerated: Bool = false,
        isVerified: Bool = true
    ) {
        self.id = id
        self.userId = userId
        self.date = date
        self.timestamp = Date()
        self.name = name
        self.photoURL = photoURL
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.carbsGrams = carbsGrams
        self.fatGrams = fatGrams
        self.fiberGrams = fiberGrams
        self.sugarGrams = sugarGrams
        self.sodiumMg = sodiumMg
        self.mealType = mealType
        self.servingSize = servingSize
        self.brand = brand
        self.barcode = barcode
        self.recognitionConfidence = recognitionConfidence
        self.isAIGenerated = isAIGenerated
        self.isVerified = isVerified
    }
}

// MARK: - Supporting Types

enum MealType: String, CaseIterable, Codable {
    case breakfast = "breakfast"
    case lunch = "lunch"
    case dinner = "dinner"
    case snack = "snack"
    
    var displayName: String {
        switch self {
        case .breakfast:
            return "Breakfast"
        case .lunch:
            return "Lunch"
        case .dinner:
            return "Dinner"
        case .snack:
            return "Snack"
        }
    }
    
    var emoji: String {
        switch self {
        case .breakfast:
            return "🌅"
        case .lunch:
            return "☀️"
        case .dinner:
            return "🌙"
        case .snack:
            return "🍎"
        }
    }
}

// MARK: - Meal Extensions

extension Meal {
    /// Total macronutrient calories (should match or be close to total calories)
    var macroCalories: Double {
        return (proteinGrams * 4) + (carbsGrams * 4) + (fatGrams * 9)
    }
    
    /// Protein percentage of total calories
    var proteinPercent: Double {
        guard calories > 0 else { return 0 }
        return (proteinGrams * 4) / calories * 100
    }
    
    /// Carbohydrate percentage of total calories
    var carbsPercent: Double {
        guard calories > 0 else { return 0 }
        return (carbsGrams * 4) / calories * 100
    }
    
    /// Fat percentage of total calories
    var fatPercent: Double {
        guard calories > 0 else { return 0 }
        return (fatGrams * 9) / calories * 100
    }
    
    /// Check if the meal's macros add up correctly
    var hasMacroDiscrepancy: Bool {
        let difference = abs(calories - macroCalories)
        return difference > (calories * 0.1) // More than 10% difference
    }
}

// MARK: - Daily Meal Summary

struct DailyMealSummary: Codable {
    let date: String
    let meals: [Meal]
    
    var totalCalories: Double {
        meals.reduce(0) { $0 + $1.calories }
    }
    
    var totalProtein: Double {
        meals.reduce(0) { $0 + $1.proteinGrams }
    }
    
    var totalCarbs: Double {
        meals.reduce(0) { $0 + $1.carbsGrams }
    }
    
    var totalFat: Double {
        meals.reduce(0) { $0 + $1.fatGrams }
    }
    
    var mealsByType: [MealType: [Meal]] {
        Dictionary(grouping: meals, by: { $0.mealType })
    }
    
    var proteinPercent: Double {
        guard totalCalories > 0 else { return 0 }
        return (totalProtein * 4) / totalCalories * 100
    }
    
    var carbsPercent: Double {
        guard totalCalories > 0 else { return 0 }
        return (totalCarbs * 4) / totalCalories * 100
    }
    
    var fatPercent: Double {
        guard totalCalories > 0 else { return 0 }
        return (totalFat * 9) / totalCalories * 100
    }
} 