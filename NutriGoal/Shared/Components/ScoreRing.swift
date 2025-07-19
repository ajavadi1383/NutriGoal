import SwiftUI

/// Circular progress ring showing lifestyle score (0-10) with emoji indicator
struct ScoreRing: View {
    let score: Double
    
    init(score: Double) {
        self.score = max(0, min(10, score)) // Clamp between 0-10
    }
    
    private var progress: Double {
        score / 10.0
    }
    
    private var emoji: String {
        if score >= 8.0 {
            return "🔥"
        } else if score >= 5.0 {
            return "🙂"
        } else {
            return "😬"
        }
    }
    
    private var ringColor: Color {
        if score >= 8.0 {
            return .green
        } else if score >= 5.0 {
            return .orange
        } else {
            return .red
        }
    }
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 12)
                .frame(width: 100, height: 100)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    ringColor,
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .frame(width: 100, height: 100)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
            
            // Center content
            VStack(spacing: 2) {
                Text(emoji)
                    .font(.title2)
                
                Text(String(format: "%.1f", score))
                    .font(.headline)
                    .fontWeight(.bold)
            }
        }
    }
}

#Preview {
    HStack(spacing: 32) {
        ScoreRing(score: 3.2)
        ScoreRing(score: 6.8)
        ScoreRing(score: 9.1)
    }
    .padding()
} 