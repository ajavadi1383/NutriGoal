import SwiftUI

// MARK: - NutriGoal Design System

/// App-wide color palette
enum NGColor {
    static let primary = Color(hex: "#3D8BFF")
    static let secondary = Color(hex: "#FFB74D")
    static let success = Color(hex: "#4CAF50")
    static let warning = Color(hex: "#FF9800")
    static let error = Color(hex: "#F44336")
    
    // Grayscale palette
    static let gray1 = Color(hex: "#F8F9FA")  // Lightest
    static let gray2 = Color(hex: "#E9ECEF")
    static let gray3 = Color(hex: "#DEE2E6")
    static let gray4 = Color(hex: "#CED4DA")
    static let gray5 = Color(hex: "#6C757D")
    static let gray6 = Color(hex: "#495057")  // Darkest
    
    // Semantic colors
    static let background = Color(hex: "#FFFFFF")
    static let surface = Color(hex: "#F8F9FA")
    static let textPrimary = Color(hex: "#212529")
    static let textSecondary = Color(hex: "#6C757D")
}

/// Typography system
enum NGFont {
    // Titles
    static let titleXL = Font.system(size: 32, weight: .bold)
    static let titleL = Font.system(size: 28, weight: .bold)
    static let titleM = Font.system(size: 24, weight: .semibold)
    static let titleS = Font.system(size: 20, weight: .semibold)
    
    // Body text
    static let bodyL = Font.system(size: 18, weight: .regular)
    static let bodyM = Font.system(size: 16, weight: .regular)
    static let bodyS = Font.system(size: 14, weight: .regular)
    
    // Labels and captions
    static let labelM = Font.system(size: 16, weight: .medium)
    static let labelS = Font.system(size: 14, weight: .medium)
    static let caption = Font.system(size: 12, weight: .regular)
}

/// Spacing and sizing constants
enum NGSize {
    // Corner radius
    static let cornerRadius: CGFloat = 12
    static let cornerRadiusS: CGFloat = 8
    static let cornerRadiusL: CGFloat = 16
    
    // Spacing
    static let spacing: CGFloat = 16
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24
    static let spacingXL: CGFloat = 32
    
    // Component sizes
    static let buttonHeight: CGFloat = 48
    static let inputHeight: CGFloat = 44
    static let iconS: CGFloat = 16
    static let iconM: CGFloat = 24
    static let iconL: CGFloat = 32
}

// MARK: - Color Extension

extension Color {
    /// Initialize Color from hex string
    /// - Parameter hex: Hex color string (e.g., "#3D8BFF" or "3D8BFF")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 