import Foundation
import FirebaseFirestore

struct Meal: Codable, Identifiable {
    var id: String?
    let loggedAt: Date
    let source: String
    let name: String
    let photoURL: URL?
    let calories: Int
    let proteinG: Int
    let carbsG: Int
    let fatG: Int
    let smartSwap: SmartSwap?
} 