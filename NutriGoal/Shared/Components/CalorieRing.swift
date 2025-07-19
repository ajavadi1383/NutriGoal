import SwiftUI

/// Circular progress ring showing calories consumed vs target range
struct CalorieRing: View {
    let consumed: Int
    let min: Int
    let max: Int
    
    init(consumed: Int, min: Int, max: Int) {
        self.consumed = consumed
        self.min = min
        self.max = max
    }
    
    private var progress: Double {
        guard max > min else { return 0 }
        return Double(consumed) / Double(max)
    }
    
    private var ringColor: Color {
        if consumed < min {
            return .orange
        } else if consumed > max {
            return .red
        } else {
            return .green
        }
    }
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 12)
                .frame(width: 120, height: 120)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: Swift.min(progress, 1.0))
                .stroke(
                    ringColor,
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
            
            // Center text
            VStack(spacing: 2) {
                Text("\(consumed)")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("kcal")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    HStack(spacing: 32) {
        CalorieRing(consumed: 1200, min: 1500, max: 2000)
        CalorieRing(consumed: 1800, min: 1500, max: 2000)
        CalorieRing(consumed: 2200, min: 1500, max: 2000)
    }
    .padding()
} 
