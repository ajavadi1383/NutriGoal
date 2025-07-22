import Foundation
import SwiftUI
import PhotosUI

@MainActor
final class MealLoggingViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let foodService: FoodRecognitionService
    private let firebaseService: FirebaseService
    
    // MARK: - Published Properties
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var selectedImage: UIImage?
    @Published var name = ""
    @Published var caloriesText = ""
    @Published var proteinText = ""
    @Published var carbsText = ""
    @Published var fatText = ""
    @Published var isSaving = false
    
    // MARK: - Computed Properties
    private var calories: Int { Int(caloriesText) ?? 0 }
    private var protein: Int { Int(proteinText) ?? 0 }
    private var carbs: Int { Int(carbsText) ?? 0 }
    private var fat: Int { Int(fatText) ?? 0 }
    
    // MARK: - Init
    init(
        foodService: FoodRecognitionService = FoodRecognitionServiceStub(),
        firebaseService: FirebaseService = FirebaseServiceImpl()
    ) {
        self.foodService = foodService
        self.firebaseService = firebaseService
    }
    
    // MARK: - Image Loading
    func loadImage() async {
        guard let photoItem = selectedPhotoItem else { return }
        
        do {
            if let data = try await photoItem.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedImage = image
                await recognise()
            }
        } catch {
            print("❌ [MealLoggingViewModel] Failed to load image: \(error)")
        }
    }
    
    // MARK: - Food Recognition
    func recognise() async {
        guard let image = selectedImage else { return }
        
        do {
            let result = try await foodService.recognise(image: image)
            
            // Fill form fields with recognition results
            name = result.name
            caloriesText = String(result.calories)
            proteinText = String(result.protein)
            carbsText = String(result.carbs)
            fatText = String(result.fat)
            
            print("✅ [MealLoggingViewModel] Food recognised: \(result.name)")
        } catch {
            print("❌ [MealLoggingViewModel] Food recognition failed: \(error)")
        }
    }
    
    // MARK: - Save Meal
    func saveTapped() async {
        guard !name.isEmpty, calories > 0 else { return }
        
        isSaving = true
        
        do {
            // Build Meal model
            let meal = Meal(
                id: UUID().uuidString,
                loggedAt: Date(),
                source: selectedImage != nil ? "photo" : "manual",
                name: name,
                photoURL: nil, // TODO: Upload photo to storage
                calories: calories,
                proteinG: protein,
                carbsG: carbs,
                fatG: fat,
                smartSwap: nil
            )
            
            // Save meal to Firebase
            let today = Date()
            try await firebaseService.save(meal: meal, for: today)
            
            // Update day stats
            try await firebaseService.updateDayStats(for: today, adding: meal)
            
            // Notify Home to refresh
            NotificationCenter.default.post(name: .mealAdded, object: nil)
            
            print("✅ [MealLoggingViewModel] Meal saved successfully")
            
        } catch {
            print("❌ [MealLoggingViewModel] Failed to save meal: \(error)")
        }
        
        isSaving = false
    }
}

// MARK: - Notifications
extension Notification.Name {
    static let mealAdded = Notification.Name("mealAdded")
} 