import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @EnvironmentObject var router: AppRouter
    
    var body: some View {
        VStack {
            // Progress indicator
            HStack {
                ForEach(0..<9, id: \.self) { index in
                    Rectangle()
                        .fill(index <= viewModel.page ? NGColor.primary : NGColor.gray3)
                        .frame(height: 4)
                        .animation(.easeInOut, value: viewModel.page)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            TabView(selection: $viewModel.page) {
                // Page 0: Birth Date
                OnboardingPageView(
                    title: "When were you born?",
                    isValid: true
                ) {
                    DatePicker("Birth Date", selection: $viewModel.birthDate, displayedComponents: .date)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                }
                .tag(0)
                
                // Page 1: Sex
                OnboardingPageView(
                    title: "What's your sex?",
                    isValid: !viewModel.sex.isEmpty
                ) {
                    VStack(spacing: NGSize.spacing) {
                        Button("Male") {
                            viewModel.sex = "male"
                        }
                        .buttonStyle(SelectionButtonStyle(isSelected: viewModel.sex == "male"))
                        
                        Button("Female") {
                            viewModel.sex = "female"
                        }
                        .buttonStyle(SelectionButtonStyle(isSelected: viewModel.sex == "female"))
                    }
                }
                .tag(1)
                
                // Page 2: Height
                OnboardingPageView(
                    title: "How tall are you?",
                    isValid: viewModel.heightCm > 0
                ) {
                    VStack {
                        Text("\(viewModel.heightCm) cm")
                            .font(NGFont.titleXL)
                        
                        Slider(value: Binding(
                            get: { Double(viewModel.heightCm) },
                            set: { viewModel.heightCm = Int($0) }
                        ), in: 120...220, step: 1)
                    }
                }
                .tag(2)
                
                // Page 3: Weight
                OnboardingPageView(
                    title: "What's your weight?",
                    isValid: viewModel.weightKg > 0
                ) {
                    VStack {
                        Text(String(format: "%.1f kg", viewModel.weightKg))
                            .font(NGFont.titleXL)
                        
                        Slider(value: $viewModel.weightKg, in: 30...200, step: 0.5)
                    }
                }
                .tag(3)
                
                // Page 4: Activity
                OnboardingPageView(
                    title: "How active are you?",
                    isValid: !viewModel.activityLevel.isEmpty
                ) {
                    VStack(spacing: NGSize.spacing) {
                        Button("1-2 days/week") {
                            viewModel.activityLevel = "1-2"
                        }
                        .buttonStyle(SelectionButtonStyle(isSelected: viewModel.activityLevel == "1-2"))
                        
                        Button("3-4 days/week") {
                            viewModel.activityLevel = "3-4"
                        }
                        .buttonStyle(SelectionButtonStyle(isSelected: viewModel.activityLevel == "3-4"))
                        
                        Button("5-6 days/week") {
                            viewModel.activityLevel = "5-6"
                        }
                        .buttonStyle(SelectionButtonStyle(isSelected: viewModel.activityLevel == "5-6"))
                    }
                }
                .tag(4)
                
                // Page 5: Target
                OnboardingPageView(
                    title: "What's your goal?",
                    isValid: !viewModel.target.isEmpty
                ) {
                    VStack(spacing: NGSize.spacing) {
                        Button("Lose weight") {
                            viewModel.target = "lose"
                        }
                        .buttonStyle(SelectionButtonStyle(isSelected: viewModel.target == "lose"))
                        
                        Button("Maintain weight") {
                            viewModel.target = "maintain"
                        }
                        .buttonStyle(SelectionButtonStyle(isSelected: viewModel.target == "maintain"))
                        
                        Button("Gain muscle") {
                            viewModel.target = "gain"
                        }
                        .buttonStyle(SelectionButtonStyle(isSelected: viewModel.target == "gain"))
                    }
                }
                .tag(5)
                
                // Page 6: Weekly Pace
                OnboardingPageView(
                    title: "Weekly pace goal?",
                    isValid: viewModel.weeklyPaceKg >= 0
                ) {
                    VStack {
                        Text(String(format: "%.1f kg/week", viewModel.weeklyPaceKg))
                            .font(NGFont.titleXL)
                        
                        Slider(value: $viewModel.weeklyPaceKg, in: 0...2, step: 0.1)
                    }
                }
                .tag(6)
                
                // Page 7: Diet Type
                OnboardingPageView(
                    title: "Any dietary preferences?",
                    isValid: !viewModel.dietType.isEmpty
                ) {
                    VStack(spacing: NGSize.spacing) {
                        Button("None") {
                            viewModel.dietType = "none"
                        }
                        .buttonStyle(SelectionButtonStyle(isSelected: viewModel.dietType == "none"))
                        
                        Button("Vegetarian") {
                            viewModel.dietType = "vegetarian"
                        }
                        .buttonStyle(SelectionButtonStyle(isSelected: viewModel.dietType == "vegetarian"))
                        
                        Button("Vegan") {
                            viewModel.dietType = "vegan"
                        }
                        .buttonStyle(SelectionButtonStyle(isSelected: viewModel.dietType == "vegan"))
                        
                        Button("Keto") {
                            viewModel.dietType = "keto"
                        }
                        .buttonStyle(SelectionButtonStyle(isSelected: viewModel.dietType == "keto"))
                    }
                }
                .tag(7)
                
                // Page 8: Language (Final)
                OnboardingPageView(
                    title: "Choose your language",
                    isValid: !viewModel.lang.isEmpty,
                    isLastPage: true
                ) {
                    VStack(spacing: NGSize.spacing) {
                        Button("English") {
                            viewModel.lang = "en"
                        }
                        .buttonStyle(SelectionButtonStyle(isSelected: viewModel.lang == "en"))
                        
                        Button("Türkçe") {
                            viewModel.lang = "tr"
                        }
                        .buttonStyle(SelectionButtonStyle(isSelected: viewModel.lang == "tr"))
                        
                        Button("Español") {
                            viewModel.lang = "es"
                        }
                        .buttonStyle(SelectionButtonStyle(isSelected: viewModel.lang == "es"))
                    }
                }
                .tag(8)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onAppear {
                viewModel.setupDependencies(router: router)
            }
        }
    }
}

struct OnboardingPageView<Content: View>: View {
    let title: String
    let isValid: Bool
    let isLastPage: Bool
    let content: Content
    
    @EnvironmentObject private var viewModel: OnboardingViewModel
    
    init(title: String, isValid: Bool, isLastPage: Bool = false, @ViewBuilder content: () -> Content) {
        self.title = title
        self.isValid = isValid
        self.isLastPage = isLastPage
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: NGSize.spacing * 2) {
            Spacer()
            
            Text(title)
                .font(NGFont.titleXL)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            content
                .padding(.horizontal)
            
            Spacer()
            
            if isLastPage {
                PrimaryButton(title: "Finish") {
                    Task {
                        await viewModel.finish()
                    }
                }
                .disabled(!isValid)
                .padding(.horizontal)
            } else {
                PrimaryButton(title: "Next") {
                    viewModel.next()
                }
                .disabled(!isValid)
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .environmentObject(viewModel)
    }
}

struct SelectionButtonStyle: ButtonStyle {
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(isSelected ? NGColor.primary : NGColor.gray2)
            .foregroundColor(isSelected ? .white : NGColor.gray6)
            .cornerRadius(NGSize.corner)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

#Preview {
    OnboardingView()
} 