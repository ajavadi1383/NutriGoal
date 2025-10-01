import Foundation

/// Nutrition calculator using Mifflin-St Jeor equation and evidence-based macro distribution
struct NutritionCalculator {
    
    // MARK: - Calculate Daily Goals
    static func calculateDailyGoals(
        birthDate: Date,
        sex: String,
        heightCm: Int,
        weightKg: Double,
        activityLevel: String,
        target: String,
        weeklyPaceKg: Double
    ) -> (calories: Int, protein: Int, carbs: Int, fat: Int) {
        
        // Calculate age
        let age = Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 25
        
        // Calculate BMR using Mifflin-St Jeor equation
        let bmr = calculateBMR(weightKg: weightKg, heightCm: heightCm, age: age, sex: sex)
        
        // Calculate TDEE
        let tdee = calculateTDEE(bmr: bmr, activityLevel: activityLevel)
        
        // Adjust for goal
        let targetCalories = adjustForGoal(tdee: tdee, target: target, weeklyPaceKg: weeklyPaceKg)
        
        // Calculate macros
        let macros = calculateMacros(calories: targetCalories, target: target)
        
        return (
            calories: Int(targetCalories),
            protein: macros.protein,
            carbs: macros.carbs,
            fat: macros.fat
        )
    }
    
    // MARK: - BMR Calculation (Mifflin-St Jeor)
    private static func calculateBMR(weightKg: Double, heightCm: Int, age: Int, sex: String) -> Double {
        let baseBMR = (10 * weightKg) + (6.25 * Double(heightCm)) - (5 * Double(age))
        return sex == "male" ? baseBMR + 5 : baseBMR - 161
    }
    
    // MARK: - TDEE Calculation
    private static func calculateTDEE(bmr: Double, activityLevel: String) -> Double {
        let multiplier: Double = switch activityLevel {
        case "1-2": 1.2      // Sedentary
        case "3-4": 1.375    // Lightly active
        case "5-6": 1.55     // Moderately active
        default: 1.375
        }
        return bmr * multiplier
    }
    
    // MARK: - Goal Adjustment
    private static func adjustForGoal(tdee: Double, target: String, weeklyPaceKg: Double) -> Double {
        switch target {
        case "lose":
            // Weight loss: deficit based on weekly pace
            // 1 kg fat = ~7700 calories, so weekly deficit = weeklyPaceKg * 7700
            let dailyDeficit = (weeklyPaceKg * 7700) / 7
            return max(tdee - dailyDeficit, 1200) // Never go below 1200 calories
            
        case "gain":
            // Muscle gain: small surplus
            return tdee + 300 // +300 calories for lean gains
            
        default: // "maintain"
            return tdee
        }
    }
    
    // MARK: - Macro Calculation
    private static func calculateMacros(calories: Double, target: String) -> (protein: Int, carbs: Int, fat: Int) {
        let macroRatios: (protein: Double, carbs: Double, fat: Double)
        
        switch target {
        case "lose":
            // High protein for muscle preservation
            macroRatios = (protein: 0.30, carbs: 0.40, fat: 0.30)
            
        case "gain":
            // High protein + high carbs for muscle building
            macroRatios = (protein: 0.25, carbs: 0.55, fat: 0.20)
            
        default: // "maintain"
            // Balanced macros
            macroRatios = (protein: 0.25, carbs: 0.45, fat: 0.30)
        }
        
        // Calculate grams (4 cal/g for protein & carbs, 9 cal/g for fat)
        let proteinGrams = Int((calories * macroRatios.protein) / 4)
        let carbsGrams = Int((calories * macroRatios.carbs) / 4)
        let fatGrams = Int((calories * macroRatios.fat) / 9)
        
        return (protein: proteinGrams, carbs: carbsGrams, fat: fatGrams)
    }
}

