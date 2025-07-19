import Foundation
import FirebaseFirestoreSwift

struct WeeklyReport: Codable, Identifiable {
    @DocumentID var id: String?
    let week: String
    let summaryText: String
    let avgScore: Double
    let suggestions: String
} 