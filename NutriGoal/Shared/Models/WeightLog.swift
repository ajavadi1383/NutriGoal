import Foundation
import FirebaseFirestoreSwift

struct WeightLog: Codable, Identifiable {
    @DocumentID var id: String?
    let loggedAt: Date
    let weightKg: Double
} 