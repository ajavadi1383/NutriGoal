//
//  OnboardingViewModel.swift
//  NutriGoal
//
//  Created by Amirali Javadi on 6/7/25.
//

import SwiftUI
import Combine

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var onboardingData = OnboardingData()
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userProfileUseCase: UserProfileUseCaseProtocol
    private let authenticationUseCase: AuthenticationUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
        userProfileUseCase: UserProfileUseCaseProtocol,
        authenticationUseCase: AuthenticationUseCaseProtocol
    ) {
        self.userProfileUseCase = userProfileUseCase
        self.authenticationUseCase = authenticationUseCase
    }
    
    // MARK: - Navigation
    
    func nextStep() {
        guard let nextStep = currentStep.next else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = nextStep
        }
    }
    
    func previousStep() {
        guard let previousStep = currentStep.previous else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = previousStep
        }
    }
    
    func canProceed() -> Bool {
        switch currentStep {
        case .welcome:
            return true
        case .personalInfo:
            return onboardingData.age != nil && 
                   onboardingData.gender != nil &&
                   onboardingData.heightCm != nil &&
                   onboardingData.weightKg != nil
        case .goals:
            return onboardingData.goal != nil
        case .targetWeight:
            // Only required for weight loss goals
            if onboardingData.goal == .loseWeight {
                return onboardingData.targetWeightKg != nil
            }
            return true
        case .activityLevel:
            return onboardingData.activityLevel != nil
        case .timeline:
            return onboardingData.targetTimeline != nil
        case .sleep:
            return onboardingData.bedtime != nil && 
                   onboardingData.sleepHours != nil
        case .coachingTone:
            return onboardingData.tone != nil
        case .summary:
            return onboardingData.isComplete
        }
    }
    
    // MARK: - Data Updates
    
    func updatePersonalInfo(age: Int, gender: Gender, heightCm: Double, weightKg: Double) {
        onboardingData.age = age
        onboardingData.gender = gender
        onboardingData.heightCm = heightCm
        onboardingData.weightKg = weightKg
    }
    
    func updateGoal(_ goal: Goal) {
        onboardingData.goal = goal
        
        // Clear target weight if switching to maintain/gain
        if goal != .loseWeight {
            onboardingData.targetWeightKg = nil
        }
    }
    
    func updateTargetWeight(_ weight: Double) {
        onboardingData.targetWeightKg = weight
    }
    
    func updateActivityLevel(_ level: ActivityLevel) {
        onboardingData.activityLevel = level
    }
    
    func updateTimeline(_ timeline: TargetTimeline) {
        onboardingData.targetTimeline = timeline
    }
    
    func updateSleep(bedtime: String, hours: Double) {
        onboardingData.bedtime = bedtime
        onboardingData.sleepHours = hours
    }
    
    func updateTone(_ tone: CoachingTone) {
        onboardingData.tone = tone
    }
    
    // MARK: - Complete Onboarding
    
    func completeOnboarding() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Create user from onboarding data
            let user = onboardingData.toUser()
            
            // Save user profile
            _ = try await userProfileUseCase.updateUserProfile(user)
            
            // Navigate to main app (handled by parent view)
            
        } catch {
            errorMessage = "Failed to save your profile. Please try again."
        }
        
        isLoading = false
    }
    
    // MARK: - Computed Properties
    
    var progressPercent: Double {
        let totalSteps = OnboardingStep.allCases.count
        let currentStepIndex = OnboardingStep.allCases.firstIndex(of: currentStep) ?? 0
        return Double(currentStepIndex) / Double(totalSteps - 1)
    }
    
    var estimatedCalorieRange: CalorieRange? {
        guard let age = onboardingData.age,
              let gender = onboardingData.gender,
              let heightCm = onboardingData.heightCm,
              let weightKg = onboardingData.weightKg,
              let activityLevel = onboardingData.activityLevel else {
            return nil
        }
        
        // Create temporary user to calculate range
        let tempUser = User(
            email: "temp",
            goal: onboardingData.goal ?? .loseWeight,
            tone: .supportive,
            heightCm: heightCm,
            weightKg: weightKg,
            activityLevel: activityLevel,
            bedtime: "23:00",
            sleepHours: 7.0,
            age: age,
            gender: gender
        )
        
        return tempUser.calorieRange
    }
}

// MARK: - Onboarding Steps

enum OnboardingStep: CaseIterable {
    case welcome
    case personalInfo
    case goals
    case targetWeight
    case activityLevel
    case timeline
    case sleep
    case coachingTone
    case summary
    
    var title: String {
        switch self {
        case .welcome:
            return "Welcome to NutriGoal"
        case .personalInfo:
            return "About You"
        case .goals:
            return "Your Goal"
        case .targetWeight:
            return "Target Weight"
        case .activityLevel:
            return "Activity Level"
        case .timeline:
            return "Timeline"
        case .sleep:
            return "Sleep Schedule"
        case .coachingTone:
            return "Coaching Style"
        case .summary:
            return "All Set!"
        }
    }
    
    var subtitle: String {
        switch self {
        case .welcome:
            return "Let's personalize your journey"
        case .personalInfo:
            return "Help us calculate your goals"
        case .goals:
            return "What would you like to achieve?"
        case .targetWeight:
            return "What's your target weight?"
        case .activityLevel:
            return "How active are you?"
        case .timeline:
            return "How fast do you want to reach your goal?"
        case .sleep:
            return "When do you usually sleep?"
        case .coachingTone:
            return "How should your AI coach talk to you?"
        case .summary:
            return "Ready to start your journey!"
        }
    }
    
    var next: OnboardingStep? {
        let all = OnboardingStep.allCases
        guard let currentIndex = all.firstIndex(of: self),
              currentIndex < all.count - 1 else { return nil }
        return all[currentIndex + 1]
    }
    
    var previous: OnboardingStep? {
        let all = OnboardingStep.allCases
        guard let currentIndex = all.firstIndex(of: self),
              currentIndex > 0 else { return nil }
        return all[currentIndex - 1]
    }
} 