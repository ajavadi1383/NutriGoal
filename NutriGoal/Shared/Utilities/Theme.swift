import SwiftUI

/// App-wide color palette
enum NGColor {
    static let primary = Color(hex: "#3D8BFF")
    static let secondary = Color(hex: "#FFB74D")
    
    // Grayscale palette
    static let gray1 = Color(hex: "#F8F9FA")
    static let gray2 = Color(hex: "#E9ECEF")
    static let gray3 = Color(hex: "#DEE2E6")
    static let gray4 = Color(hex: "#CED4DA")
    static let gray5 = Color(hex: "#6C757D")
    static let gray6 = Color(hex: "#495057")
}

/// Typography system
enum NGFont {
    static let titleXL = Font.system(size: 32, weight: .bold)
    static let bodyM = Font.system(size: 16, weight: .regular)
}

/// Spacing and sizing constants
enum NGSize {
    static let corner: CGFloat = 12
    static let spacing: CGFloat = 16
}

// MARK: - Color Extension

extension Color {
    /// Initialize Color from hex string
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
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 