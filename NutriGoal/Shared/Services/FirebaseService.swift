import Foundation
import FirebaseFirestore
import FirebaseAuth

protocol FirebaseService {
    func save(profile: UserProfile) async throws
}

final class FirebaseServiceImpl: FirebaseService {
    private let db = Firestore.firestore()
    
    func save(profile: UserProfile) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw FirebaseServiceError.noAuthenticatedUser
        }
        
        do {
            try await db.collection("users").document(uid).setData([
                "id": uid,
                "email": profile.email,
                "birthDate": profile.birthDate,
                "sex": profile.sex,
                "heightCm": profile.heightCm,
                "weightKg": profile.weightKg,
                "activityLevel": profile.activityLevel,
                "target": profile.target,
                "weeklyPaceKg": profile.weeklyPaceKg,
                "goalDate": profile.goalDate,
                "dietType": profile.dietType,
                "lang": profile.lang,
                "createdAt": profile.createdAt
            ])
        } catch {
            print("❌ [\(#function)] \(error.localizedDescription)")
            throw error
        }
    }
}

enum FirebaseServiceError: Error {
    case noAuthenticatedUser
    case saveFailed
}

// Resolver.register { FirebaseServiceImpl() as FirebaseService } 