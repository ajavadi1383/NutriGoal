//
//  AppConfiguration.swift
//  NutriGoal
//
//  Created by Amirali Javadi on 6/7/25.
//

import Foundation

struct AppConfiguration {
    static let shared = AppConfiguration()
    
    private init() {}
    
    // MARK: - Environment
    enum Environment {
        case development
        case production
        
        static var current: Environment {
            #if DEBUG
            return .development
            #else
            return .production
            #endif
        }
    }
    
    // MARK: - API Configuration
    struct API {
        static let openAIBaseURL = "https://api.openai.com/v1"
        static let openFoodFactsBaseURL = "https://world.openfoodfacts.org/api/v0"
        static let usdaBaseURL = "https://api.nal.usda.gov/fdc/v1"
        
        // API Keys - These should be stored securely in practice
        static var openAIAPIKey: String {
            // TODO: Move to secure storage
            return Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String ?? ""
        }
        
        static var usdaAPIKey: String {
            // TODO: Move to secure storage
            return Bundle.main.object(forInfoDictionaryKey: "USDA_API_KEY") as? String ?? ""
        }
    }
    
    // MARK: - App Constants
    struct Constants {
        static let appName = "NutriGoal"
        static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        
        // Subscription Products
        static let monthlySubscriptionID = "nutrigoal.monthly.999"
        static let yearlySubscriptionID = "nutrigoal.yearly.5999"
        
        // Lifestyle Score Parameters
        static let maxLifestyleScore: Double = 10.0
        static let minLifestyleScore: Double = 0.0
        
        // Default Values
        static let defaultWaterGoalLiters: Double = 2.0
        static let defaultStepsGoal: Int = 8000
        static let defaultSleepHours: Double = 7.0
    }
    
    // MARK: - HealthKit Configuration
    struct HealthKit {
        static let readTypes: [String] = [
            "HKQuantityTypeIdentifierStepCount",
            "HKQuantityTypeIdentifierActiveEnergyBurned",
            "HKCategoryTypeIdentifierSleepAnalysis",
            "HKQuantityTypeIdentifierBodyMass",
            "HKQuantityTypeIdentifierHeartRate"
        ]
        
        static let writeTypes: [String] = [
            "HKQuantityTypeIdentifierBodyMass"
        ]
    }
} 