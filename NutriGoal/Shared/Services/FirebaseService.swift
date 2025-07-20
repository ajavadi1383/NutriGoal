import Foundation
import FirebaseFirestore
import FirebaseAuth

protocol FirebaseService {
    func save(profile: UserProfile) async throws
    func deleteUserData(uid: String) async throws
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
    
    func deleteUserData(uid: String) async throws {
        print("🗑️ [FirebaseService] Deleting all user data for uid: \(uid)")
        
        do {
            // Delete main user document
            let userRef = db.collection("users").document(uid)
            
            // Delete all subcollections
            let collections = ["meals", "dayStats", "weightLogs", "weeklyReports", "chat_messages"]
            
            for collectionName in collections {
                print("🗑️ [FirebaseService] Deleting \(collectionName) subcollection")
                let subcollectionRef = userRef.collection(collectionName)
                let documents = try await subcollectionRef.getDocuments()
                
                // Delete all documents in subcollection
                for document in documents.documents {
                    try await document.reference.delete()
                }
            }
            
            // Finally delete the main user document
            try await userRef.delete()
            print("✅ [FirebaseService] All user data deleted successfully")
            
        } catch {
            print("❌ [FirebaseService] Delete user data failed: \(error)")
            throw error
        }
    }
}

enum FirebaseServiceError: Error {
    case noAuthenticatedUser
    case saveFailed
    case deleteFailed
}

// Resolver.register { FirebaseServiceImpl() as FirebaseService } 