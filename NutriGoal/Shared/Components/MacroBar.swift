import SwiftUI

/// Horizontal progress bar showing macro nutrient progress with current/target labels
struct MacroBar: View {
    let name: String
    let progress: Double
    let current: Int
    let min: Int
    let max: Int
    
    init(name: String, progress: Double, current: Int, min: Int, max: Int) {
        self.name = name
        self.progress = progress
        self.current = current
        self.min = min
        self.max = max
    }
    
    private var statusText: String {
        if current < min {
            return "below range"
        } else if current > max {
            return "over"
        } else {
            return "in range"
        }
    }
    
    private var progressColor: Color {
        if current < min {
            return .orange
        } else if current > max {
            return .red
        } else {
            return .green
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("\(name) \(current)g")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text(statusText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Progress bar
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 8)
                .overlay(
                    HStack {
                        Capsule()
                            .fill(progressColor)
                            .frame(width: Swift.max(0, CGFloat(progress) * 200))
                        Spacer(minLength: 0)
                    }
                )
                .frame(width: 200)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        MacroBar(name: "Protein", progress: 0.8, current: 120, min: 100, max: 150)
        MacroBar(name: "Carbs", progress: 1.2, current: 180, min: 150, max: 200)
        MacroBar(name: "Fat", progress: 0.4, current: 30, min: 50, max: 80)
    }
    .padding()
} 
