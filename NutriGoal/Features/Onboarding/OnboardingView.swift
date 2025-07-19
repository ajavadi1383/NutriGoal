import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel: OnboardingViewModel
    private let onComplete: () -> Void
    
    init(authManager: AuthManager, onComplete: @escaping () -> Void) {
        // TODO: Inject FirebaseService when implemented
        self._viewModel = StateObject(wrappedValue: OnboardingViewModel(authManager: authManager, firebaseService: nil))
        self.onComplete = onComplete
    }
    
    var body: some View {
        VStack {
            // TODO: Add progress indicator UI polish
            ProgressView(value: Double(viewModel.currentStep + 1), total: 8)
                .progressViewStyle(LinearProgressViewStyle())
                .padding()
            
            TabView(selection: $viewModel.currentStep) {
                birthDateStep.tag(0)
                sexStep.tag(1)
                heightStep.tag(2)
                weightStep.tag(3)
                activityStep.tag(4)
                targetStep.tag(5)
                goalPaceStep.tag(6)
                dietTypeStep.tag(7)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            Spacer()
            
            Button(viewModel.currentStep == 7 ? "Finish" : "Next") {
                if viewModel.currentStep == 7 {
                    Task {
                        await viewModel.finishOnboarding()
                        onComplete()
                    }
                } else {
                    viewModel.nextStep()
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canProceed)
            .padding()
        }
        .navigationBarBackButtonHidden()
    }
    
    // MARK: - Step Views
    
    private var birthDateStep: some View {
        VStack(spacing: 20) {
            Text("When were you born?")
                .font(.title2)
                .multilineTextAlignment(.center)
            
            DatePicker("Birth Date", selection: $viewModel.birthDate, displayedComponents: .date)
                .datePickerStyle(.wheel)
        }
        .padding()
    }
    
    private var sexStep: some View {
        VStack(spacing: 20) {
            Text("What's your biological sex?")
                .font(.title2)
                .multilineTextAlignment(.center)
            
            Picker("Sex", selection: $viewModel.sex) {
                Text("Male").tag("male")
                Text("Female").tag("female")
            }
            .pickerStyle(.segmented)
        }
        .padding()
    }
    
    private var heightStep: some View {
        VStack(spacing: 20) {
            Text("What's your height?")
                .font(.title2)
                .multilineTextAlignment(.center)
            
            HStack {
                TextField("Height (cm)", value: $viewModel.heightCm, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                Text("cm")
            }
        }
        .padding()
    }
    
    private var weightStep: some View {
        VStack(spacing: 20) {
            Text("What's your current weight?")
                .font(.title2)
                .multilineTextAlignment(.center)
            
            HStack {
                TextField("Weight (kg)", value: $viewModel.weightKg, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                Text("kg")
            }
        }
        .padding()
    }
    
    private var activityStep: some View {
        VStack(spacing: 20) {
            Text("How active are you?")
                .font(.title2)
                .multilineTextAlignment(.center)
            
            Picker("Activity Level", selection: $viewModel.activityLevel) {
                Text("1-2 days/week").tag("1-2")
                Text("3-4 days/week").tag("3-4")
                Text("5-6 days/week").tag("5-6")
            }
            .pickerStyle(.wheel)
        }
        .padding()
    }
    
    private var targetStep: some View {
        VStack(spacing: 20) {
            Text("What's your goal?")
                .font(.title2)
                .multilineTextAlignment(.center)
            
            Picker("Target", selection: $viewModel.target) {
                Text("Lose Weight").tag("weight_loss")
                Text("Maintain Weight").tag("maintain")
                Text("Gain Muscle").tag("gain_muscle")
            }
            .pickerStyle(.wheel)
        }
        .padding()
    }
    
    private var goalPaceStep: some View {
        VStack(spacing: 20) {
            Text("Weekly pace (kg per week)?")
                .font(.title2)
                .multilineTextAlignment(.center)
            
            HStack {
                TextField("Pace", value: $viewModel.weeklyPaceKg, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                Text("kg/week")
            }
        }
        .padding()
    }
    
    private var dietTypeStep: some View {
        VStack(spacing: 20) {
            Text("Any dietary preferences?")
                .font(.title2)
                .multilineTextAlignment(.center)
            
            Picker("Diet Type", selection: $viewModel.dietType) {
                Text("No restrictions").tag("none")
                Text("Vegan").tag("vegan")
                Text("Vegetarian").tag("vegetarian")
                Text("Keto").tag("keto")
                Text("Paleo").tag("paleo")
            }
            .pickerStyle(.wheel)
        }
        .padding()
    }
} 