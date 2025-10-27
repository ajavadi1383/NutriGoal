# AppConfig

Centralized configuration values for external services.

```swift
struct AppConfig {
    static var openAIAPIKey: String { /* reads from GoogleService-Info.plist (key: "OpenAI API Key") */ }
    static let openAIBaseURL = "https://api.openai.com/v1"
    static let chatCompletionsEndpoint = "\(openAIBaseURL)/chat/completions"

    static let gptVisionModel = "gpt-4o"
    static let maxTokens = 300
    static let temperature = 0.1
}
```

Secrets:
- Place `OpenAI API Key` in `GoogleService-Info.plist`.

Models used by OpenAI:
- `OpenAIRequest`, `OpenAIMessage`, `OpenAIContent`, `OpenAIImageURL`, `OpenAIResponse`, `OpenAIChoice`, `OpenAIResponseMessage`, `NutritionEstimate`.

Notes:
- `temperature` kept low for consistent nutrition estimates.