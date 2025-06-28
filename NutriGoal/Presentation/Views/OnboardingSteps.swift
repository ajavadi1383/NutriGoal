//
//  OnboardingSteps.swift
//  NutriGoal
//
//  Created by Amirali Javadi on 6/7/25.
//

import SwiftUI

// MARK: - Personal Info Step

struct OnboardingPersonalInfoView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var ageText = ""
    @State private var heightText = ""
    @State private var weightText = ""
    @State private var selectedGender: Gender = .male
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                headerView(title: "About You", subtitle: "Help us calculate your personalized goals")
                
                VStack(spacing: 25) {
                    // Age Input
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Age")
                            .font(.headline)
                            .foregroundColor(.white)
                        TextField("Enter your age", text: $ageText)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                            .font(.body)
                    }
                    
                    // Gender Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Gender")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 8) {
                            ForEach(Gender.allCases, id: \.self) { gender in
                                Button(action: {
                                    selectedGender = gender
                                    updateData()
                                }) {
                                    Text(gender.displayName)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(selectedGender == gender ? .white : .white.opacity(0.8))
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 16)
                                        .background(selectedGender == gender ? Color.white.opacity(0.3) : Color.white.opacity(0.1))
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                }
                            }
                        }
                    }
                    
                    // Height Input
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Height (cm)")
                            .font(.headline)
                            .foregroundColor(.white)
                        TextField("Enter your height", text: $heightText)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                            .font(.body)
                    }
                    
                    // Weight Input
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Current Weight (kg)")
                            .font(.headline)
                            .foregroundColor(.white)
                        TextField("Enter your weight", text: $weightText)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                            .font(.body)
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer(minLength: 100)
            }
        }
        .onAppear {
            loadCurrentData()
        }
        .onChange(of: ageText) { _ in updateData() }
        .onChange(of: heightText) { _ in updateData() }
        .onChange(of: weightText) { _ in updateData() }
    }
    
    private func loadCurrentData() {
        if let age = viewModel.onboardingData.age {
            ageText = String(age)
        }
        if let gender = viewModel.onboardingData.gender {
            selectedGender = gender
        }
        if let height = viewModel.onboardingData.heightCm {
            heightText = String(height)
        }
        if let weight = viewModel.onboardingData.weightKg {
            weightText = String(weight)
        }
    }
    
    private func updateData() {
        guard let age = Int(ageText),
              let height = Double(heightText),
              let weight = Double(weightText) else { return }
        
        viewModel.updatePersonalInfo(
            age: age,
            gender: selectedGender,
            heightCm: height,
            weightKg: weight
        )
    }
}

// MARK: - Goals Step

struct OnboardingGoalsView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var selectedGoal: Goal?
    
    var body: some View {
        VStack(spacing: 30) {
            headerView(title: "Your Goal", subtitle: "What would you like to achieve?")
            
            VStack(spacing: 16) {
                ForEach(Goal.allCases, id: \.self) { goal in
                    GoalCard(
                        goal: goal,
                        isSelected: selectedGoal == goal,
                        onTap: {
                            selectedGoal = goal
                            viewModel.updateGoal(goal)
                        }
                    )
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
        .onAppear {
            selectedGoal = viewModel.onboardingData.goal
        }
    }
}

struct GoalCard: View {
    let goal: Goal
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(goal.displayName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(goalDescription(for: goal))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? Color(red: 0.2, green: 0.4, blue: 1.0) : .gray.opacity(0.6))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.95))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color(red: 0.2, green: 0.4, blue: 1.0) : Color.clear,
                        lineWidth: 2
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }
    
    private func goalDescription(for goal: Goal) -> String {
        switch goal {
        case .loseWeight:
            return "Reduce body weight through calorie deficit"
        case .maintainWeight:
            return "Keep current weight while building healthy habits"
        case .gainMuscle:
            return "Build muscle mass through strength training"
        }
    }
}

// MARK: - Target Weight Step

struct OnboardingTargetWeightView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var targetWeightText = ""
    
    var body: some View {
        VStack(spacing: 30) {
            headerView(title: "Target Weight", subtitle: "What's your goal weight?")
            
            VStack(spacing: 25) {
                if let currentWeight = viewModel.onboardingData.weightKg {
                    VStack(spacing: 8) {
                        Text("Current Weight")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        Text("\(currentWeight, specifier: "%.1f") kg")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Target Weight (kg)")
                        .font(.headline)
                        .foregroundColor(.white)
                    TextField("Enter your target weight", text: $targetWeightText)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(12)
                        .font(.title2)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 30)
                
                if let current = viewModel.onboardingData.weightKg,
                   let target = Double(targetWeightText) {
                    let difference = current - target
                    if difference > 0 {
                        VStack(spacing: 8) {
                            Text("Weight Loss Goal")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                            Text("Lose \(difference, specifier: "%.1f") kg")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(12)
                    }
                }
            }
            
            Spacer()
        }
        .onAppear {
            if let targetWeight = viewModel.onboardingData.targetWeightKg {
                targetWeightText = String(targetWeight)
            }
        }
        .onChange(of: targetWeightText) { _ in
            if let weight = Double(targetWeightText) {
                viewModel.updateTargetWeight(weight)
            }
        }
    }
}

// MARK: - Activity Level Step

struct OnboardingActivityLevelView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var selectedLevel: ActivityLevel?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                headerView(title: "Activity Level", subtitle: "How active are you?")
                
                VStack(spacing: 16) {
                    ForEach(ActivityLevel.allCases, id: \.self) { level in
                        ActivityLevelCard(
                            level: level,
                            isSelected: selectedLevel == level,
                            onTap: {
                                selectedLevel = level
                                viewModel.updateActivityLevel(level)
                            }
                        )
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer(minLength: 100)
            }
        }
        .onAppear {
            selectedLevel = viewModel.onboardingData.activityLevel
        }
    }
}

struct ActivityLevelCard: View {
    let level: ActivityLevel
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(level.displayName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundColor(isSelected ? Color(red: 0.2, green: 0.4, blue: 1.0) : .gray.opacity(0.6))
                }
                
                Text(activityDescription(for: level))
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.95))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color(red: 0.2, green: 0.4, blue: 1.0) : Color.clear,
                        lineWidth: 2
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }
    
    private func activityDescription(for level: ActivityLevel) -> String {
        switch level {
        case .sedentary:
            return "Little to no exercise, desk job"
        case .lightlyActive:
            return "Light exercise 1-3 days per week"
        case .moderatelyActive:
            return "Moderate exercise 3-5 days per week"
        case .veryActive:
            return "Heavy exercise 6-7 days per week"
        case .extremelyActive:
            return "Very heavy exercise, physical job"
        }
    }
}

// MARK: - Timeline Step

struct OnboardingTimelineView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var selectedTimeline: TargetTimeline?
    
    var body: some View {
        VStack(spacing: 30) {
            headerView(title: "Timeline", subtitle: "How fast do you want to reach your goal?")
            
            VStack(spacing: 16) {
                ForEach(TargetTimeline.allCases, id: \.self) { timeline in
                    Button(action: {
                        selectedTimeline = timeline
                        viewModel.updateTimeline(timeline)
                    }) {
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(timeline.displayName)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                Text(timeline.description)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            Image(systemName: selectedTimeline == timeline ? "checkmark.circle.fill" : "circle")
                                .font(.title3)
                                .foregroundColor(selectedTimeline == timeline ? Color(red: 0.2, green: 0.4, blue: 1.0) : .gray.opacity(0.6))
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.95))
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    selectedTimeline == timeline ? Color(red: 0.2, green: 0.4, blue: 1.0) : Color.clear,
                                    lineWidth: 2
                                )
                        )
                        .scaleEffect(selectedTimeline == timeline ? 1.02 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: selectedTimeline)
                    }
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
        .onAppear {
            selectedTimeline = viewModel.onboardingData.targetTimeline
        }
    }
}

// MARK: - Sleep Step

struct OnboardingSleepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var selectedBedtime = Date()
    @State private var sleepHours: Double = 7.0
    
    var body: some View {
        VStack(spacing: 30) {
            headerView(title: "Sleep Schedule", subtitle: "When do you usually sleep?")
            
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Text("Bedtime")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    DatePicker("Bedtime", selection: $selectedBedtime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(16)
                }
                
                VStack(spacing: 16) {
                    Text("Sleep Duration: \(sleepHours, specifier: "%.1f") hours")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 12) {
                        Slider(value: $sleepHours, in: 5...10, step: 0.5)
                            .accentColor(Color(red: 0.2, green: 0.4, blue: 1.0))
                        
                        HStack {
                            Text("5h")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            Spacer()
                            Text("10h")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(16)
                }
                .padding(.horizontal, 30)
            }
            
            Spacer()
        }
        .onAppear {
            loadCurrentData()
        }
        .onChange(of: selectedBedtime) { _ in updateData() }
        .onChange(of: sleepHours) { _ in updateData() }
    }
    
    private func loadCurrentData() {
        if let bedtime = viewModel.onboardingData.bedtime {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            if let date = formatter.date(from: bedtime) {
                selectedBedtime = date
            }
        }
        if let hours = viewModel.onboardingData.sleepHours {
            sleepHours = hours
        }
    }
    
    private func updateData() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let bedtimeString = formatter.string(from: selectedBedtime)
        viewModel.updateSleep(bedtime: bedtimeString, hours: sleepHours)
    }
}

// MARK: - Coaching Tone Step

struct OnboardingCoachingToneView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var selectedTone: CoachingTone?
    
    var body: some View {
        VStack(spacing: 30) {
            headerView(title: "Coaching Style", subtitle: "How should your AI coach talk to you?")
            
            VStack(spacing: 16) {
                ForEach(CoachingTone.allCases, id: \.self) { tone in
                    Button(action: {
                        selectedTone = tone
                        viewModel.updateTone(tone)
                    }) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(tone.displayName)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: selectedTone == tone ? "checkmark.circle.fill" : "circle")
                                    .font(.title3)
                                    .foregroundColor(selectedTone == tone ? Color(red: 0.2, green: 0.4, blue: 1.0) : .gray.opacity(0.6))
                            }
                            Text(toneDescription(for: tone))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.95))
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    selectedTone == tone ? Color(red: 0.2, green: 0.4, blue: 1.0) : Color.clear,
                                    lineWidth: 2
                                )
                        )
                        .scaleEffect(selectedTone == tone ? 1.02 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: selectedTone)
                    }
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
        .onAppear {
            selectedTone = viewModel.onboardingData.tone
        }
    }
    
    private func toneDescription(for tone: CoachingTone) -> String {
        switch tone {
        case .supportive:
            return "Gentle, encouraging, and understanding"
        case .motivational:
            return "Energetic, enthusiastic, and inspiring"
        case .analytical:
            return "Data-focused, logical, and informative"
        }
    }
}

// MARK: - Summary Step

struct OnboardingSummaryView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                headerView(title: "All Set!", subtitle: "Here's your personalized plan")
                
                VStack(spacing: 20) {
                    if let calorieRange = viewModel.estimatedCalorieRange {
                        SummaryCard(
                            title: "Daily Calories",
                            value: "\(Int(calorieRange.min))-\(Int(calorieRange.max)) kcal",
                            subtitle: "Your personalized range"
                        )
                    }
                    
                    SummaryCard(
                        title: "Goal",
                        value: viewModel.onboardingData.goal?.displayName ?? "",
                        subtitle: viewModel.onboardingData.targetTimeline?.displayName ?? ""
                    )
                    
                    SummaryCard(
                        title: "AI Coach",
                        value: viewModel.onboardingData.tone?.displayName ?? "",
                        subtitle: "Your coaching style"
                    )
                }
                .padding(.horizontal, 30)
                
                Text("🎉 Ready to start your journey!")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Spacer(minLength: 100)
            }
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray.opacity(0.8))
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(Color(red: 0.2, green: 0.4, blue: 1.0))
            }
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.95))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Helper Views

func headerView(title: String, subtitle: String) -> some View {
    VStack(spacing: 12) {
        Text(title)
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
        
        Text(subtitle)
            .font(.title3)
            .foregroundColor(.white.opacity(0.9))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
    }
    .padding(.top, 20)
} 