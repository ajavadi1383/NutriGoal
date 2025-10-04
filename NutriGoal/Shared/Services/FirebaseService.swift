import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import UIKit

// MARK: - Protocol
protocol FirebaseService {
    func save(profile: UserProfile) async throws
    func deleteUserData(uid: String) async throws
    func save(meal: Meal, for date: Date) async throws
    func updateDayStats(for date: Date, adding meal: Meal) async throws
    func fetchMeals(for date: Date) async throws -> [Meal]
    func uploadFoodPhoto(image: UIImage, mealId: String) async throws -> URL
}

// MARK: - Implementation
final class FirebaseServiceImpl: FirebaseService {
    
    private let db = Firestore.firestore()
    
    // MARK: - User Profile
    func save(profile: UserProfile) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])
        }

        try await db.collection("users").document(uid).setData([
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
        
        print("✅ [FirebaseService] User profile saved for UID: \(uid)")
    }
    
    func deleteUserData(uid: String) async throws {
        // Delete user document
        try await db.collection("users").document(uid).delete()
        print("✅ [FirebaseService] User data deleted for UID: \(uid)")
    }
    
    // MARK: - Meals
    func save(meal: Meal, for date: Date) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])
        }
        
        // Ensure unique ID for each meal
        let mealId = meal.id ?? UUID().uuidString
        
        let mealData: [String: Any] = [
            "id": mealId,  // Save the ID in the document
            "loggedAt": Timestamp(date: meal.loggedAt),  // Use Firestore Timestamp
            "source": meal.source,
            "name": meal.name,
            "photoURL": meal.photoURL?.absoluteString ?? NSNull(),
            "calories": meal.calories,
            "proteinG": meal.proteinG,
            "carbsG": meal.carbsG,
            "fatG": meal.fatG,
            "smartSwap": meal.smartSwap != nil ? [
                "suggestion": meal.smartSwap!.suggestion,
                "newCalories": meal.smartSwap!.newCalories,
                "newProteinG": meal.smartSwap!.newProteinG,
                "newCarbsG": meal.smartSwap!.newCarbsG,
                "newFatG": meal.smartSwap!.newFatG
            ] : NSNull()
        ]
        
        try await db.collection("users").document(uid)
            .collection("meals").document(mealId)  // Use the unique ID
            .setData(mealData, merge: false)  // Don't merge, create new document
        
        print("✅ [FirebaseService] Meal saved with ID \(mealId): \(meal.name)")
    }
    
    func updateDayStats(for date: Date, adding meal: Meal) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])
        }
        
        let dateString = DateFormatter.yyyyMMdd.string(from: date)
        let dayStatsRef = db.collection("users").document(uid)
            .collection("dayStats").document(dateString)
        
        // Get existing stats or create new
        let document = try await dayStatsRef.getDocument()
        let currentStats = try? document.data(as: DayStats.self)
        
        // Calculate new totals (add meal to existing or start from 0)
        let newCaloriesTotal = (currentStats?.caloriesTotal ?? 0) + meal.calories
        let newProteinTotal = (currentStats?.proteinTotal ?? 0) + meal.proteinG
        let newCarbsTotal = (currentStats?.carbsTotal ?? 0) + meal.carbsG
        let newFatTotal = (currentStats?.fatTotal ?? 0) + meal.fatG
        
        // Create updated stats object
        let updatedStats = DayStats(
            id: dateString,
            date: dateString,
            caloriesTotal: newCaloriesTotal,
            proteinTotal: newProteinTotal,
            carbsTotal: newCarbsTotal,
            fatTotal: newFatTotal,
            steps: currentStats?.steps ?? 0,
            workoutMin: currentStats?.workoutMin ?? 0,
            waterMl: currentStats?.waterMl ?? 0,
            sleepMin: currentStats?.sleepMin ?? 0,
            bedtime: currentStats?.bedtime ?? "22:00",
            score: currentStats?.score ?? 0.0
        )
        
        // Save updated stats
        try await dayStatsRef.setData([
            "date": updatedStats.date,
            "caloriesTotal": updatedStats.caloriesTotal,
            "proteinTotal": updatedStats.proteinTotal,
            "carbsTotal": updatedStats.carbsTotal,
            "fatTotal": updatedStats.fatTotal,
            "steps": updatedStats.steps,
            "workoutMin": updatedStats.workoutMin,
            "waterMl": updatedStats.waterMl,
            "sleepMin": updatedStats.sleepMin,
            "bedtime": updatedStats.bedtime,
            "score": updatedStats.score
        ])
        
        print("✅ [FirebaseService] Day stats updated for \(dateString): +\(meal.calories) cal, +\(meal.proteinG)g protein")
    }
    
    func fetchMeals(for date: Date) async throws -> [Meal] {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])
        }
        
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let snapshot = try await db.collection("users").document(uid)
            .collection("meals")
            .whereField("loggedAt", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("loggedAt", isLessThan: Timestamp(date: endOfDay))
            .order(by: "loggedAt", descending: true)
            .getDocuments()
        
        let meals = snapshot.documents.compactMap { document -> Meal? in
            let data = document.data()
            
            // Manual parsing to ensure unique data for each meal
            guard let id = data["id"] as? String,
                  let loggedAtTimestamp = data["loggedAt"] as? Timestamp,
                  let source = data["source"] as? String,
                  let name = data["name"] as? String,
                  let calories = data["calories"] as? Int,
                  let proteinG = data["proteinG"] as? Int,
                  let carbsG = data["carbsG"] as? Int,
                  let fatG = data["fatG"] as? Int else {
                print("⚠️ [FirebaseService] Skipping invalid meal document: \(document.documentID)")
                return nil
            }
            
            let photoURLString = data["photoURL"] as? String
            let photoURL = photoURLString.flatMap { URL(string: $0) }
            
            print("📝 [FirebaseService] Fetched meal: \(name) (\(id)) - \(calories) cal")
            
            return Meal(
                id: id,
                loggedAt: loggedAtTimestamp.dateValue(),
                source: source,
                name: name,
                photoURL: photoURL,
                calories: calories,
                proteinG: proteinG,
                carbsG: carbsG,
                fatG: fatG,
                smartSwap: nil
            )
        }
        
        print("✅ [FirebaseService] Fetched \(meals.count) meals for \(date)")
        return meals
    }
}

    // MARK: - Photo Upload
    func uploadFoodPhoto(image: UIImage, mealId: String) async throws -> URL {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])
        }
        
        // Compress image
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw NSError(domain: "FirebaseService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])
        }
        
        // Create storage reference
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let photoPath = "users/\(uid)/meals/\(mealId).jpg"
        let photoRef = storageRef.child(photoPath)
        
        // Upload image
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        _ = try await photoRef.putDataAsync(imageData, metadata: metadata)
        
        // Get download URL
        let downloadURL = try await photoRef.downloadURL()
        
        print("✅ [FirebaseService] Photo uploaded: \(downloadURL.absoluteString)")
        return downloadURL
    }
}

// MARK: - Date Formatter Extension
private extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
} 
