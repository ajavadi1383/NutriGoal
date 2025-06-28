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
                VStack(spacing: 8) {
                    HStack {
                        Text("Step \(OnboardingStep.allCases.firstIndex(of: viewModel.currentStep)! + 1) of \(OnboardingStep.allCases.count)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                        Text("\(Int(viewModel.progressPercent * 100))%")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    
                    ProgressView(value: viewModel.progressPercent)
                        .progressViewStyle(LinearProgressViewStyle(tint: .white))
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(4)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
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
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.4, blue: 1.0),
                    Color(red: 0.4, green: 0.2, blue: 0.9)
                ]),
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
        HStack(spacing: 16) {
            // Back Button
            if viewModel.currentStep != .welcome {
                Button("Back") {
                    viewModel.previousStep()
                }
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.vertical, 16)
                .padding(.horizontal, 32)
                .background(Color.white.opacity(0.2))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
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
            .fontWeight(.semibold)
            .foregroundColor(viewModel.canProceed() ? Color(red: 0.2, green: 0.4, blue: 1.0) : .gray)
            .padding(.vertical, 16)
            .padding(.horizontal, 32)
            .background(viewModel.canProceed() ? Color.white : Color.white.opacity(0.5))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            .disabled(!viewModel.canProceed() || viewModel.isLoading)
            .scaleEffect(viewModel.canProceed() ? 1.0 : 0.95)
            .animation(.easeInOut(duration: 0.2), value: viewModel.canProceed())
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.2, green: 0.4, blue: 1.0)))
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