import Foundation
import FirebaseFirestore

struct WeeklyReport: Codable, Identifiable {
    var id: String?
    let week: String
    let summaryText: String
    let avgScore: Double
    let suggestions: String
} 