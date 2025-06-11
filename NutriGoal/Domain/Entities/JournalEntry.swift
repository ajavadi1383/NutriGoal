//
//  JournalEntry.swift
//  NutriGoal
//
//  Created by Amirali Javadi on 6/7/25.
//

import Foundation

struct JournalEntry: Identifiable, Codable {
    let id: String
    let userId: String
    let date: String // Format: "YYYY-MM-DD"
    let timestamp: Date
    
    // Journal Content
    var entryText: String
    var mood: String?
    
    // Daily Metrics (used for AI generation)
    var score: Double
    var calories: Double
    var proteinGrams: Double
    var carbsGrams: Double
    var fatGrams: Double
    var steps: Int
    var workoutMinutes: Double
    var sleepHours: Double
    var bedtime: String // Format: "HH:MM"
    var waterLiters: Double
    
    // AI Generation metadata
    var isAIGenerated: Bool
    var generationPrompt: String?
    var tone: CoachingTone
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        date: String,
        entryText: String,
        mood: String? = nil,
        score: Double,
        calories: Double,
        proteinGrams: Double,
        carbsGrams: Double,
        fatGrams: Double,
        steps: Int,
        workoutMinutes: Double,
        sleepHours: Double,
        bedtime: String,
        waterLiters: Double,
        isAIGenerated: Bool = true,
        generationPrompt: String? = nil,
        tone: CoachingTone
    ) {
        self.id = id
        self.userId = userId
        self.date = date
        self.timestamp = Date()
        self.entryText = entryText
        self.mood = mood
        self.score = score
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.carbsGrams = carbsGrams
        self.fatGrams = fatGrams
        self.steps = steps
        self.workoutMinutes = workoutMinutes
        self.sleepHours = sleepHours
        self.bedtime = bedtime
        self.waterLiters = waterLiters
        self.isAIGenerated = isAIGenerated
        self.generationPrompt = generationPrompt
        self.tone = tone
    }
}

// MARK: - Lifestyle Score

struct LifestyleScore: Codable {
    let date: String
    let overallScore: Double
    let components: ScoreComponents
    let timestamp: Date
    
    init(date: String, components: ScoreComponents) {
        self.date = date
        self.components = components
        self.timestamp = Date()
        
        // Calculate overall score as weighted average
        self.overallScore = Self.calculateOverallScore(from: components)
    }
    
    private static func calculateOverallScore(from components: ScoreComponents) -> Double {
        let weights: [Double] = [
            0.25, // nutrition (calories + macros)
            0.20, // activity (steps + workouts)
            0.20, // sleep (duration + consistency)
            0.15, // hydration
            0.10, // consistency (streak factors)
            0.10  // additional factors
        ]
        
        let scores = [
            components.nutritionScore,
            components.activityScore,
            components.sleepScore,
            components.hydrationScore,
            components.consistencyScore,
            components.additionalScore
        ]
        
        let weightedSum = zip(scores, weights).reduce(0.0) { sum, pair in
            sum + (pair.0 * pair.1)
        }
        
        return min(max(weightedSum, 0.0), 10.0) // Clamp between 0-10
    }
}

struct ScoreComponents: Codable {
    // Individual component scores (0-10 each)
    let nutritionScore: Double      // Calorie adherence + macro balance
    let activityScore: Double       // Steps + workout minutes
    let sleepScore: Double          // Sleep duration + bedtime consistency
    let hydrationScore: Double      // Water intake vs goal
    let consistencyScore: Double    // Streak and habit consistency
    let additionalScore: Double     // Mood, stress, other factors
    
    // Detailed breakdowns
    let calorieAdherence: Double    // How well calories fit target range
    let macroBalance: Double        // How well macros match targets
    let stepsScore: Double          // Steps vs goal
    let workoutScore: Double        // Workout minutes
    let sleepDuration: Double       // Sleep hours vs target
    let bedtimeConsistency: Double  // Consistency with target bedtime
    
    init(
        calorieAdherence: Double,
        macroBalance: Double,
        stepsScore: Double,
        workoutScore: Double,
        sleepDuration: Double,
        bedtimeConsistency: Double,
        hydrationScore: Double,
        consistencyScore: Double = 5.0,
        additionalScore: Double = 5.0
    ) {
        self.calorieAdherence = calorieAdherence
        self.macroBalance = macroBalance
        self.stepsScore = stepsScore
        self.workoutScore = workoutScore
        self.sleepDuration = sleepDuration
        self.bedtimeConsistency = bedtimeConsistency
        self.hydrationScore = hydrationScore
        self.consistencyScore = consistencyScore
        self.additionalScore = additionalScore
        
        // Calculate composite scores
        self.nutritionScore = (calorieAdherence * 0.6) + (macroBalance * 0.4)
        self.activityScore = (stepsScore * 0.6) + (workoutScore * 0.4)
        self.sleepScore = (sleepDuration * 0.7) + (bedtimeConsistency * 0.3)
    }
}

// MARK: - Score Calculator

struct LifestyleScoreCalculator {
    static func calculateScore(
        user: User,
        dailyMeals: DailyMealSummary,
        steps: Int,
        workoutMinutes: Double,
        sleepHours: Double,
        actualBedtime: String,
        waterLiters: Double
    ) -> LifestyleScore {
        
        let calorieAdherence = calculateCalorieAdherence(
            consumed: dailyMeals.totalCalories,
            targetRange: user.calorieRange
        )
        
        let macroBalance = calculateMacroBalance(
            consumed: (
                protein: dailyMeals.totalProtein,
                carbs: dailyMeals.totalCarbs,
                fat: dailyMeals.totalFat
            ),
            targets: user.macroTargets
        )
        
        let stepsScore = calculateStepsScore(
            steps: steps,
            goal: AppConfiguration.Constants.defaultStepsGoal
        )
        
        let workoutScore = calculateWorkoutScore(minutes: workoutMinutes)
        
        let sleepDurationScore = calculateSleepDurationScore(
            actualHours: sleepHours,
            targetHours: user.sleepHours
        )
        
        let bedtimeConsistency = calculateBedtimeConsistency(
            actualBedtime: actualBedtime,
            targetBedtime: user.bedtime
        )
        
        let hydrationScore = calculateHydrationScore(
            waterLiters: waterLiters,
            goal: AppConfiguration.Constants.defaultWaterGoalLiters
        )
        
        let components = ScoreComponents(
            calorieAdherence: calorieAdherence,
            macroBalance: macroBalance,
            stepsScore: stepsScore,
            workoutScore: workoutScore,
            sleepDuration: sleepDurationScore,
            bedtimeConsistency: bedtimeConsistency,
            hydrationScore: hydrationScore
        )
        
        return LifestyleScore(
            date: DateFormatter.dateString(from: Date()),
            components: components
        )
    }
    
    // MARK: - Individual Score Calculations
    
    private static func calculateCalorieAdherence(consumed: Double, targetRange: CalorieRange) -> Double {
        if targetRange.contains(consumed) {
            return 10.0 // Perfect adherence
        }
        
        let midpoint = (targetRange.min + targetRange.max) / 2
        let deviation = abs(consumed - midpoint)
        let tolerance = (targetRange.max - targetRange.min) / 2
        
        // Score decreases as deviation increases
        let score = max(0, 10 - (deviation / tolerance * 5))
        return min(score, 10.0)
    }
    
    private static func calculateMacroBalance(
        consumed: (protein: Double, carbs: Double, fat: Double),
        targets: MacroTargets
    ) -> Double {
        let proteinDiff = abs(consumed.protein - targets.proteinGrams) / targets.proteinGrams
        let carbsDiff = abs(consumed.carbs - targets.carbsGrams) / targets.carbsGrams
        let fatDiff = abs(consumed.fat - targets.fatGrams) / targets.fatGrams
        
        let avgDeviation = (proteinDiff + carbsDiff + fatDiff) / 3
        let score = max(0, 10 - (avgDeviation * 10))
        return min(score, 10.0)
    }
    
    private static func calculateStepsScore(steps: Int, goal: Int) -> Double {
        let ratio = Double(steps) / Double(goal)
        if ratio >= 1.0 {
            return 10.0
        }
        return ratio * 10.0
    }
    
    private static func calculateWorkoutScore(minutes: Double) -> Double {
        // 30 minutes = perfect score, scales linearly
        return min(minutes / 30.0 * 10.0, 10.0)
    }
    
    private static func calculateSleepDurationScore(actualHours: Double, targetHours: Double) -> Double {
        let difference = abs(actualHours - targetHours)
        if difference <= 0.5 {
            return 10.0 // Within 30 minutes
        }
        let score = max(0, 10 - (difference * 2))
        return score
    }
    
    private static func calculateBedtimeConsistency(actualBedtime: String, targetBedtime: String) -> Double {
        // Convert to minutes for easier calculation
        let actualMinutes = timeStringToMinutes(actualBedtime)
        let targetMinutes = timeStringToMinutes(targetBedtime)
        
        let difference = abs(actualMinutes - targetMinutes)
        if difference <= 30 {
            return 10.0 // Within 30 minutes
        }
        let score = max(0, 10 - (Double(difference) / 60.0 * 2))
        return score
    }
    
    private static func calculateHydrationScore(waterLiters: Double, goal: Double) -> Double {
        let ratio = waterLiters / goal
        if ratio >= 1.0 {
            return 10.0
        }
        return ratio * 10.0
    }
    
    private static func timeStringToMinutes(_ timeString: String) -> Int {
        let components = timeString.split(separator: ":").compactMap { Int($0) }
        guard components.count == 2 else { return 0 }
        return components[0] * 60 + components[1]
    }
}

// MARK: - Extensions

extension DateFormatter {
    static func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
} 