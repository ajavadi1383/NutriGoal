import Foundation
import UIKit

// MARK: - Protocol
protocol FoodRecognitionService {
    func recognise(image: UIImage) async throws -> (name: String, calories: Int, protein: Int, carbs: Int, fat: Int)
}

// MARK: - Stub Implementation
final class FoodRecognitionServiceStub: FoodRecognitionService {
    
    func recognise(image: UIImage) async throws -> (name: String, calories: Int, protein: Int, carbs: Int, fat: Int) {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        // Return dummy "Chicken & Rice" macros
        return (
            name: "Chicken & Rice",
            calories: 450,
            protein: 35,
            carbs: 45,
            fat: 12
        )
    }
}

// MARK: - Resolver Registration
// Resolver.register { FoodRecognitionServiceStub() as FoodRecognitionService } 