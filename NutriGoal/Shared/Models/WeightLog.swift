import Foundation
import FirebaseFirestore

struct WeightLog: Codable, Identifiable {
    var id: String?
    let loggedAt: Date
    let weightKg: Double
} 