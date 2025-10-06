import Foundation

struct AppConfig {
    
    // MARK: - OpenAI Configuration
    static var openAIAPIKey: String {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let apiKey = plist["OpenAI API Key"] as? String else {
            fatalError("OpenAI API Key not found in GoogleService-Info.plist")
        }
        return apiKey
    }
    
    // MARK: - OpenAI Endpoints
    static let openAIBaseURL = "https://api.openai.com/v1"
    static let chatCompletionsEndpoint = "\(openAIBaseURL)/chat/completions"
    
    // MARK: - Model Configuration  
    static let gptVisionModel = "gpt-4o"
    static let maxTokens = 500 // Increased for detailed analysis
    static let temperature = 0.05 // Very low temperature for maximum consistency and accuracy
} 