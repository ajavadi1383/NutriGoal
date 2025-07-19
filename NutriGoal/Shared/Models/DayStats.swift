import Foundation
import FirebaseFirestoreSwift

struct DayStats: Codable, Identifiable {
    @DocumentID var id: String?
    let date: String
    let caloriesTotal: Int
    let proteinTotal: Int
    let carbsTotal: Int
    let fatTotal: Int
    let steps: Int
    let workoutMin: Int
    let waterMl: Int
    let sleepMin: Int
    let bedtime: String
    let score: Double
} 