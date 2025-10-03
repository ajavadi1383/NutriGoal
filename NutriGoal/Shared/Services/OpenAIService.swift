import Foundation
import UIKit

// MARK: - Structured Output Request Models
struct OpenAIRequest: Codable {
    let model: String
    let messages: [OpenAIMessage]
    let maxTokens: Int
    let temperature: Double
    let responseFormat: ResponseFormat
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
        case responseFormat = "response_format"
    }
}

struct ResponseFormat: Codable {
    let type: String
    let jsonSchema: JSONSchemaFormat
    
    enum CodingKeys: String, CodingKey {
        case type
        case jsonSchema = "json_schema"
    }
}

struct JSONSchemaFormat: Codable {
    let name: String
    let strict: Bool
    let schema: JSONSchema
}

struct JSONSchema: Codable {
    let type: String
    let properties: [String: SchemaProperty]
    let required: [String]
    let additionalProperties: Bool
}

struct SchemaProperty: Codable {
    let type: String
    let description: String?
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
    let detail: String?
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

// MARK: - Nutrition Response Model (Structured Output)
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
        
        // Prepare request with Structured Output
        let request = OpenAIRequest(
            model: "gpt-4o-2024-08-06",
            messages: [
                OpenAIMessage(
                    role: "user",
                    content: [
                        OpenAIContent(
                            type: "text",
                            text: """
                            Analyze this food image and provide accurate nutritional estimates.
                            Identify the food item and estimate the total calories and macronutrients for the entire portion shown.
                            Be as precise as possible based on typical serving sizes and visual portion estimation.
                            """,
                            imageUrl: nil
                        ),
                        OpenAIContent(
                            type: "image_url",
                            text: nil,
                            imageUrl: OpenAIImageURL(url: dataURL, detail: "low")
                        )
                    ]
                )
            ],
            maxTokens: 300,
            temperature: 0.1,
            responseFormat: ResponseFormat(
                type: "json_schema",
                jsonSchema: JSONSchemaFormat(
                    name: "nutrition_estimate",
                    strict: true,
                    schema: JSONSchema(
                        type: "object",
                        properties: [
                            "name": SchemaProperty(type: "string", description: "The name of the food item"),
                            "calories": SchemaProperty(type: "integer", description: "Total calories in the portion"),
                            "protein": SchemaProperty(type: "integer", description: "Protein in grams"),
                            "carbs": SchemaProperty(type: "integer", description: "Carbohydrates in grams"),
                            "fat": SchemaProperty(type: "integer", description: "Fat in grams")
                        ],
                        required: ["name", "calories", "protein", "carbs", "fat"],
                        additionalProperties: false
                    )
                )
            )
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