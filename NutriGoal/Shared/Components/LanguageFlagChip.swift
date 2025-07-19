import SwiftUI

/// Small capsule chip displaying country flag and language code
struct LanguageFlagChip: View {
    let code: String
    
    init(code: String) {
        self.code = code.lowercased()
    }
    
    private var flagImageName: String {
        // Map language codes to country flag SF Symbols
        switch code {
        case "en":
            return "flag.us"
        case "tr":
            return "flag.tr"
        case "es":
            return "flag.es"
        case "zh":
            return "flag.cn"
        default:
            return "flag"
        }
    }
    
    private var displayName: String {
        Locale.current.localizedString(forLanguageCode: code)?.capitalized ?? code.uppercased()
    }
    
    var body: some View {
        HStack(spacing: 6) {
            // Flag icon
            Image(systemName: flagImageName)
                .font(.caption)
                .foregroundColor(.primary)
            
            // Language code
            Text(code.uppercased())
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.gray.opacity(0.15))
        )
        .overlay(
            Capsule()
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 12) {
        HStack(spacing: 12) {
            LanguageFlagChip(code: "en")
            LanguageFlagChip(code: "tr")
        }
        
        HStack(spacing: 12) {
            LanguageFlagChip(code: "es")
            LanguageFlagChip(code: "zh")
        }
    }
    .padding()
} 