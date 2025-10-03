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
        // No fallback - throw errors so UI can handle properly
        return try await openAIService.recognizeFood(from: image)
    }
}



// MARK: - Resolver Registration
// Use real OpenAI implementation:
// Resolver.register { FoodRecognitionServiceImpl() as FoodRecognitionService }
// Use stub for testing:
// Resolver.register { FoodRecognitionServiceStub() as FoodRecognitionService } 
