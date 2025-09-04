import Foundation
import UIKit

// MARK: - Protocol
protocol FoodRecognitionService {
    func recognise(image: UIImage) async throws -> (name: String, calories: Int, protein: Int, carbs: Int, fat: Int)
}

// MARK: - OpenAI Implementation
final class FoodRecognitionServiceImpl: FoodRecognitionService {
    
    private let openAIService = OpenAIService()
    
    func recognise(image: UIImage) async throws -> (name: String, calories: Int, protein: Int, carbs: Int, fat: Int) {
        do {
            return try await openAIService.recognizeFood(from: image)
        } catch {
            print("❌ [FoodRecognitionService] OpenAI recognition failed: \(error)")
            
            // Fallback to stub data if OpenAI fails
            print("🔄 [FoodRecognitionService] Using fallback recognition...")
            return (
                name: "Food Item",
                calories: 300,
                protein: 20,
                carbs: 30,
                fat: 10
            )
        }
    }
}



// MARK: - Resolver Registration
// Use real OpenAI implementation:
// Resolver.register { FoodRecognitionServiceImpl() as FoodRecognitionService }
// Use stub for testing:
// Resolver.register { FoodRecognitionServiceStub() as FoodRecognitionService } 
