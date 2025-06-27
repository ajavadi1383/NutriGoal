//
//  OnboardingFlow.swift
//  NutriGoal
//
//  Created by Amirali Javadi on 6/7/25.
//

import SwiftUI

struct OnboardingFlow: View {
    @EnvironmentObject var diContainer: DIContainer
    @StateObject private var viewModel: OnboardingViewModel
    @Binding var isOnboardingComplete: Bool
    
    init(isOnboardingComplete: Binding<Bool>) {
        self._isOnboardingComplete = isOnboardingComplete
        self._viewModel = StateObject(wrappedValue: OnboardingViewModel(
            userProfileUseCase: DIContainer.shared.userProfileUseCase,
            authenticationUseCase: DIContainer.shared.authenticationUseCase
        ))
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Progress Bar
                ProgressView(value: viewModel.progressPercent)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                
                // Main Content
                TabView(selection: $viewModel.currentStep) {
                    ForEach(OnboardingStep.allCases, id: \.self) { step in
                        stepView(for: step)
                            .tag(step)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
                
                // Navigation Buttons
                navigationButtons
                    .padding(.horizontal, 20)
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .onChange(of: viewModel.isLoading) { isLoading in
            if !isLoading && viewModel.errorMessage == nil && viewModel.currentStep == .summary {
                // Onboarding completed successfully
                isOnboardingComplete = true
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
    
    @ViewBuilder
    private func stepView(for step: OnboardingStep) -> some View {
        switch step {
        case .welcome:
            OnboardingWelcomeView()
        case .personalInfo:
            OnboardingPersonalInfoView(viewModel: viewModel)
        case .goals:
            OnboardingGoalsView(viewModel: viewModel)
        case .targetWeight:
            if viewModel.onboardingData.goal == .loseWeight {
                OnboardingTargetWeightView(viewModel: viewModel)
            } else {
                EmptyView()
            }
        case .activityLevel:
            OnboardingActivityLevelView(viewModel: viewModel)
        case .timeline:
            OnboardingTimelineView(viewModel: viewModel)
        case .sleep:
            OnboardingSleepView(viewModel: viewModel)
        case .coachingTone:
            OnboardingCoachingToneView(viewModel: viewModel)
        case .summary:
            OnboardingSummaryView(viewModel: viewModel)
        }
    }
    
    private var navigationButtons: some View {
        HStack {
            // Back Button
            if viewModel.currentStep != .welcome {
                Button("Back") {
                    viewModel.previousStep()
                }
                .font(.headline)
                .foregroundColor(.blue)
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 1)
                )
            }
            
            Spacer()
            
            // Next/Complete Button
            Button(buttonTitle) {
                if viewModel.currentStep == .summary {
                    Task {
                        await viewModel.completeOnboarding()
                    }
                } else {
                    handleNextStep()
                }
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .background(viewModel.canProceed() ? Color.blue : Color.gray)
            .cornerRadius(8)
            .disabled(!viewModel.canProceed() || viewModel.isLoading)
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
            }
        }
    }
    
    private var buttonTitle: String {
        if viewModel.isLoading {
            return ""
        } else if viewModel.currentStep == .summary {
            return "Start Journey"
        } else {
            return "Continue"
        }
    }
    
    private func handleNextStep() {
        // Skip target weight step if not losing weight
        if viewModel.currentStep == .goals && viewModel.onboardingData.goal != .loseWeight {
            viewModel.nextStep() // Go to targetWeight
            viewModel.nextStep() // Skip to activityLevel
        } else {
            viewModel.nextStep()
        }
    }
}

// MARK: - Step Views

struct OnboardingWelcomeView: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Welcome to NutriGoal")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Let's personalize your health journey with AI-powered insights")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            VStack(spacing: 20) {
                FeatureItem(
                    icon: "brain.head.profile",
                    title: "AI Daily Journals",
                    description: "Personalized insights about your progress"
                )
                
                FeatureItem(
                    icon: "message.fill",
                    title: "Personal Coach",
                    description: "24/7 motivation and guidance"
                )
                
                FeatureItem(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Lifestyle Score",
                    description: "Holistic tracking of your wellness"
                )
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

struct FeatureItem: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingFlow(isOnboardingComplete: .constant(false))
        .environmentObject(DIContainer.shared)
} 