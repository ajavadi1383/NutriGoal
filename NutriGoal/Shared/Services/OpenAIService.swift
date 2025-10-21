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
                            You are an expert nutritionist and food analyst. Analyze this food image with precision.
                            
                            INSTRUCTIONS:
                            1. Identify the specific food item(s) visible in the image
                            2. Estimate the portion size based on visual cues (plate size, utensils, comparisons)
                            3. Consider cooking method (fried/grilled/baked affects calories)
                            4. Account for visible ingredients, sauces, and toppings
                            5. Provide conservative estimates - it's better to slightly overestimate calories for weight loss
                            
                            PORTION SIZE GUIDELINES:
                            - Compare to standard references: fist = 1 cup, palm = 3-4oz protein, thumb = 1oz cheese
                            - Restaurant portions are typically 1.5-2x larger than home portions
                            - Consider the entire plate if multiple items visible
                            
                            MACRO DISTRIBUTION:
                            - Protein: Meats, fish, eggs, dairy, legumes (4 cal/g)
                            - Carbs: Grains, bread, pasta, fruits, vegetables (4 cal/g)
                            - Fats: Oils, butter, nuts, avocado, cheese (9 cal/g)
                            
                            Provide your best estimate for the TOTAL PORTION shown in the image.
                            Be specific with the food name (e.g., "Grilled Chicken Breast with Rice" not just "Chicken").
                            """,
                            imageUrl: nil
                        ),
                        OpenAIContent(
                            type: "image_url",
                            text: nil,
                            imageUrl: OpenAIImageURL(url: dataURL, detail: "high")
                        )
                    ]
                )
            ],
            maxTokens: AppConfig.maxTokens,
            temperature: AppConfig.temperature,
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
    
    // MARK: - Weekly Report Generation
    func generateWeeklyReport(
        dayStats: [DayStats],
        avgCalories: Int,
        avgProtein: Int,
        avgSteps: Int,
        userGoals: (calories: Int, protein: Int, carbs: Int, fat: Int)?
    ) async throws -> String {
        
        // Prepare weekly data summary
        let weekSummary = """
        Week Overview:
        - Days tracked: \(dayStats.count) out of 7
        - Average daily calories: \(avgCalories) kcal
        - Average daily protein: \(avgProtein)g
        - Average daily steps: \(avgSteps)
        
        Daily Breakdown:
        \(dayStats.map { "• \($0.date): \($0.caloriesTotal) cal, \($0.proteinTotal)g protein, \($0.carbsTotal)g carbs, \($0.fatTotal)g fat, \($0.steps) steps, Score: \($0.score)/10" }.joined(separator: "\n"))
        """
        
        let goalsInfo = userGoals.map { goals in
            "\nUser's Goals: \(goals.calories) cal, \(goals.protein)g protein, \(goals.carbs)g carbs, \(goals.fat)g fat per day"
        } ?? ""
        
        // Create the prompt for GPT-4
        let prompt = """
        You are an expert nutritionist. Analyze this week's data against the user's goals and provide a realistic, honest weekly assessment.
        
        \(weekSummary)\(goalsInfo)
        
        Write a SHORT (100-150 words), honest report with:
        
        1. PERFORMANCE vs GOALS (2-3 sentences)
           - Compare actual averages to targets
           - State if they're on track, over, or under
           - Use specific numbers and percentages
        
        2. KEY ISSUE or STRENGTH (1-2 sentences)
           - Identify the most important pattern (good or bad)
           - Be direct and realistic - don't sugarcoat
        
        3. ONE ACTIONABLE FIX (1-2 sentences)
           - The single most important thing to improve next week
           - Be specific and measurable
        
        RULES:
        - NO cliches ("journey", "crushing it", "you've got this")
        - NO excessive emojis (1-2 max)
        - Be respectful but HONEST - if they're off track, say it clearly
        - Focus on DATA and RESULTS, not motivation
        - If goals are missing, analyze against healthy standards
        
        Keep it under 150 words. Be concise and useful.
        """
        
        // Prepare request
        let messages = [
            OpenAIMessage(
                role: "user",
                content: [
                    OpenAIContent(
                        type: "text",
                        text: prompt,
                        imageUrl: nil
                    )
                ]
            )
        ]
        
        var urlRequest = URLRequest(url: URL(string: AppConfig.chatCompletionsEndpoint)!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(AppConfig.openAIAPIKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",  // Cost-effective for text generation
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 250,  // Shorter reports
            "temperature": 0.3  // More factual, less creative
        ]
        
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        print("📊 [OpenAIService] Generating AI weekly report...")
        
        // Make request
        let (data, response) = try await session.data(for: urlRequest)
        
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
        
        let reportText = choice.message.content.trimmingCharacters(in: .whitespacesAndNewlines)
        print("✅ [OpenAIService] AI weekly report generated (\(reportText.count) chars)")
        
        return reportText
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