import Foundation
import UIKit

// MARK: - OpenAI Models
struct OpenAIRequest: Codable {
    let model: String
    let messages: [OpenAIMessage]
    let maxTokens: Int
    let temperature: Double
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
    }
}

struct OpenAIMessage: Codable {
    let role: String
    let content: [OpenAIContent]
}

struct OpenAIContent: Codable {
    let type: String
    let text: String?
    let imageUrl: OpenAIImageURL?
    
    enum CodingKeys: String, CodingKey {
        case type, text
        case imageUrl = "image_url"
    }
}

struct OpenAIImageURL: Codable {
    let url: String
}

struct OpenAIResponse: Codable {
    let choices: [OpenAIChoice]
}

struct OpenAIChoice: Codable {
    let message: OpenAIResponseMessage
}

struct OpenAIResponseMessage: Codable {
    let content: String
}

// MARK: - Nutrition Response Model
struct NutritionEstimate: Codable {
    let name: String
    let calories: Int
    let protein: Int
    let carbs: Int
    let fat: Int
}

// MARK: - OpenAI Service
final class OpenAIService {
    
    private let session = URLSession.shared
    
    func recognizeFood(from image: UIImage) async throws -> (name: String, calories: Int, protein: Int, carbs: Int, fat: Int) {
        
        // Convert image to base64
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw OpenAIError.imageProcessingFailed
        }
        let base64Image = imageData.base64EncodedString()
        let dataURL = "data:image/jpeg;base64,\(base64Image)"
        
        // Prepare request
        let request = OpenAIRequest(
            model: AppConfig.gptVisionModel,
            messages: [
                OpenAIMessage(
                    role: "user",
                    content: [
                        OpenAIContent(
                            type: "text",
                            text: """
                            Analyze this food image and provide nutritional estimates. 
                            Respond ONLY with valid JSON in this exact format:
                            {"name": "Food Name", "calories": 450, "protein": 25, "carbs": 45, "fat": 15}
                            
                            Estimate the total calories and macros for the entire portion shown.
                            Be as accurate as possible based on typical serving sizes.
                            """,
                            imageUrl: nil
                        ),
                        OpenAIContent(
                            type: "image_url",
                            text: nil,
                            imageUrl: OpenAIImageURL(url: dataURL)
                        )
                    ]
                )
            ],
            maxTokens: AppConfig.maxTokens,
            temperature: AppConfig.temperature
        )
        
        // Create URL request
        var urlRequest = URLRequest(url: URL(string: AppConfig.chatCompletionsEndpoint)!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(AppConfig.openAIAPIKey)", forHTTPHeaderField: "Authorization")
        
        // Encode request body
        let requestData = try JSONEncoder().encode(request)
        urlRequest.httpBody = requestData
        
        print("🤖 [OpenAIService] Sending food recognition request to GPT-4 Vision...")
        
        // Make request
        let (data, response) = try await session.data(for: urlRequest)
        
        // Check response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            print("❌ [OpenAIService] HTTP Error: \(httpResponse.statusCode)")
            if let errorString = String(data: data, encoding: .utf8) {
                print("❌ [OpenAIService] Error response: \(errorString)")
            }
            throw OpenAIError.apiError(httpResponse.statusCode)
        }
        
        // Parse response
        let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        
        guard let choice = openAIResponse.choices.first else {
            throw OpenAIError.noResponse
        }
        
        let jsonString = choice.message.content.trimmingCharacters(in: .whitespacesAndNewlines)
        print("🤖 [OpenAIService] GPT-4 Vision response: \(jsonString)")
        
        // Parse nutrition JSON
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw OpenAIError.invalidJSON
        }
        
        let nutrition = try JSONDecoder().decode(NutritionEstimate.self, from: jsonData)
        
        print("✅ [OpenAIService] Food recognized: \(nutrition.name) - \(nutrition.calories) cal")
        
        return (
            name: nutrition.name,
            calories: nutrition.calories,
            protein: nutrition.protein,
            carbs: nutrition.carbs,
            fat: nutrition.fat
        )
    }
}

// MARK: - Errors
enum OpenAIError: Error, LocalizedError {
    case imageProcessingFailed
    case invalidResponse
    case apiError(Int)
    case noResponse
    case invalidJSON
    
    var errorDescription: String? {
        switch self {
        case .imageProcessingFailed:
            return "Failed to process image"
        case .invalidResponse:
            return "Invalid response from OpenAI"
        case .apiError(let code):
            return "OpenAI API error: \(code)"
        case .noResponse:
            return "No response from OpenAI"
        case .invalidJSON:
            return "Invalid JSON response"
        }
    }
} 