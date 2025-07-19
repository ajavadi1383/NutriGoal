import Foundation
import FirebaseFirestoreSwift

struct UserProfile: Codable, Identifiable {
    @DocumentID var id: String?
    let email: String
    let birthDate: Date
    let sex: String
    let heightCm: Int
    let weightKg: Double
    let activityLevel: String
    let target: String
    let weeklyPaceKg: Double
    let goalDate: Date
    let dietType: String
    let lang: String
    let createdAt: Date
} 