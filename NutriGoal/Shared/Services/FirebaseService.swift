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
    func fetchDayStats(for date: Date) async throws -> DayStats?
    func fetchDayStatsRange(from startDate: Date, to endDate: Date) async throws -> [DayStats]
    func saveWeightLog(weightKg: Double) async throws
    func fetchWeightLogs(from startDate: Date, to endDate: Date) async throws -> [WeightLog]
    func fetchUserProfile() async throws -> UserProfile?
    func saveWeeklyReport(weekId: String, reportText: String, avgScore: Double, weekStart: Date) async throws
    func fetchWeeklyReports() async throws -> [(weekId: String, reportText: String, avgScore: Double, weekStart: Date)]
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
    
    // MARK: - Photo Upload
    func uploadFoodPhoto(image: UIImage, mealId: String) async throws -> URL {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])
        }
        
        print("📸 [FirebaseService] Starting photo upload for meal: \(mealId)")
        
        // Compress image
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            print("❌ [FirebaseService] Failed to compress image")
            throw NSError(domain: "FirebaseService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])
        }
        
        print("✅ [FirebaseService] Image compressed: \(imageData.count) bytes")
        
        do {
            // Create storage reference with proper bucket URL
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let photoPath = "users/\(uid)/meals/\(mealId).jpg"
            let photoRef = storageRef.child(photoPath)
            
            print("📤 [FirebaseService] Uploading to path: \(photoPath)")
            
            // Upload image
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            let uploadTask = try await photoRef.putDataAsync(imageData, metadata: metadata)
            print("✅ [FirebaseService] Upload complete: \(uploadTask)")
            
            // Get download URL
            let downloadURL = try await photoRef.downloadURL()
            print("✅ [FirebaseService] Photo uploaded successfully: \(downloadURL.absoluteString)")
            
            return downloadURL
            
        } catch let error as NSError {
            print("❌ [FirebaseService] Photo upload failed with error: \(error)")
            print("❌ [FirebaseService] Error domain: \(error.domain), code: \(error.code)")
            print("❌ [FirebaseService] Error description: \(error.localizedDescription)")
            
            // Re-throw the error
            throw error
        }
    }
    
    // MARK: - Day Stats
    func fetchDayStats(for date: Date) async throws -> DayStats? {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FirebaseService", code: 401)
        }
        
        let dateString = DateFormatter.yyyyMMdd.string(from: date)
        let document = try await db.collection("users").document(uid)
            .collection("dayStats").document(dateString)
            .getDocument()
        
        guard document.exists else { return nil }
        return try? document.data(as: DayStats.self)
    }
    
    func fetchDayStatsRange(from startDate: Date, to endDate: Date) async throws -> [DayStats] {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FirebaseService", code: 401)
        }
        
        let startString = DateFormatter.yyyyMMdd.string(from: startDate)
        let endString = DateFormatter.yyyyMMdd.string(from: endDate)
        
        let snapshot = try await db.collection("users").document(uid)
            .collection("dayStats")
            .whereField("date", isGreaterThanOrEqualTo: startString)
            .whereField("date", isLessThanOrEqualTo: endString)
            .order(by: "date")
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: DayStats.self) }
    }
    
    // MARK: - Weight Logs
    func saveWeightLog(weightKg: Double) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FirebaseService", code: 401)
        }
        
        let weightLog = WeightLog(
            id: UUID().uuidString,
            loggedAt: Date(),
            weightKg: weightKg
        )
        
        try await db.collection("users").document(uid)
            .collection("weightLogs").document(weightLog.id ?? UUID().uuidString)
            .setData([
                "loggedAt": Timestamp(date: weightLog.loggedAt),
                "weightKg": weightLog.weightKg
            ])
        
        print("✅ [FirebaseService] Weight logged: \(weightKg) kg")
    }
    
    func fetchWeightLogs(from startDate: Date, to endDate: Date) async throws -> [WeightLog] {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FirebaseService", code: 401)
        }
        
        let snapshot = try await db.collection("users").document(uid)
            .collection("weightLogs")
            .whereField("loggedAt", isGreaterThanOrEqualTo: Timestamp(date: startDate))
            .whereField("loggedAt", isLessThanOrEqualTo: Timestamp(date: endDate))
            .order(by: "loggedAt")
            .getDocuments()
        
        return snapshot.documents.compactMap { document -> WeightLog? in
            guard let id = document.documentID as String?,
                  let loggedAtTimestamp = document.data()["loggedAt"] as? Timestamp,
                  let weightKg = document.data()["weightKg"] as? Double else {
                return nil
            }
            
            return WeightLog(
                id: id,
                loggedAt: loggedAtTimestamp.dateValue(),
                weightKg: weightKg
            )
        }
    }
    
    // MARK: - User Profile
    func fetchUserProfile() async throws -> UserProfile? {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FirebaseService", code: 401)
        }
        
        let document = try await db.collection("users").document(uid).getDocument()
        
        guard document.exists else {
            print("⚠️ [FirebaseService] No user profile found for UID: \(uid)")
            return nil
        }
        
        return try? document.data(as: UserProfile.self)
    }
    
    // MARK: - Weekly Reports
    func saveWeeklyReport(weekId: String, reportText: String, avgScore: Double, weekStart: Date) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])
        }
        
        let reportData: [String: Any] = [
            "weekId": weekId,
            "reportText": reportText,
            "avgScore": avgScore,
            "weekStart": Timestamp(date: weekStart),
            "generatedAt": Timestamp(date: Date())
        ]
        
        try await db.collection("users").document(uid)
            .collection("weeklyReports").document(weekId)
            .setData(reportData)
        
        print("✅ [FirebaseService] Weekly report saved: \(weekId)")
    }
    
    func fetchWeeklyReports() async throws -> [(weekId: String, reportText: String, avgScore: Double, weekStart: Date)] {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])
        }
        
        let snapshot = try await db.collection("users").document(uid)
            .collection("weeklyReports")
            .order(by: "weekStart", descending: true)
            .limit(to: 10)  // Last 10 weeks
            .getDocuments()
        
        let reports = snapshot.documents.compactMap { document -> (String, String, Double, Date)? in
            let data = document.data()
            
            guard let weekId = data["weekId"] as? String,
                  let reportText = data["reportText"] as? String,
                  let avgScore = data["avgScore"] as? Double,
                  let weekStartTimestamp = data["weekStart"] as? Timestamp else {
                return nil
            }
            
            return (weekId, reportText, avgScore, weekStartTimestamp.dateValue())
        }
        
        print("✅ [FirebaseService] Fetched \(reports.count) weekly reports")
        return reports
    }
}

// MARK: - Date Formatter Extension
extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
} 
