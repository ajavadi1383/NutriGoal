import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @EnvironmentObject var router: AppRouter
    
    var body: some View {
        HeroBaseView {
            VStack {
                // Progress indicator with white styling
                HStack {
                    ForEach(0..<9, id: \.self) { index in
                        Rectangle()
                            .fill(index <= viewModel.page ? .white : Color.white.opacity(0.3))
                            .frame(height: 4)
                            .animation(.easeInOut, value: viewModel.page)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                TabView(selection: $viewModel.page) {
                    // Page 0: Birth Date
                    HeroPageView(title: "When were you born?") {
                        DatePicker("Birth Date", selection: $viewModel.birthDate, displayedComponents: .date)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .colorScheme(.dark) // White text on gradient
                    }
                    .tag(0)
                    
                    // Page 1: Sex
                    HeroPageView(title: "What's your sex?") {
                        VStack(spacing: NGSize.spacing) {
                            Button("Male") {
                                viewModel.sex = "male"
                            }
                            .buttonStyle(HeroSelectionButtonStyle(isSelected: viewModel.sex == "male"))
                            
                            Button("Female") {
                                viewModel.sex = "female"
                            }
                            .buttonStyle(HeroSelectionButtonStyle(isSelected: viewModel.sex == "female"))
                        }
                    }
                    .tag(1)
                    
                    // Page 2: Height
                    HeroPageView(title: "How tall are you?") {
                        VStack {
                            Text("\(viewModel.heightCm) cm")
                                .font(NGFont.titleXL)
                                .foregroundColor(.white)
                            
                            Slider(value: Binding(
                                get: { Double(viewModel.heightCm) },
                                set: { viewModel.heightCm = Int($0) }
                            ), in: 120...220, step: 1)
                            .accentColor(.white)
                        }
                    }
                    .tag(2)
                    
                    // Page 3: Weight
                    HeroPageView(title: "What's your weight?") {
                        VStack {
                            Text(String(format: "%.1f kg", viewModel.weightKg))
                                .font(NGFont.titleXL)
                                .foregroundColor(.white)
                            
                            Slider(value: $viewModel.weightKg, in: 30...200, step: 0.5)
                                .accentColor(.white)
                        }
                    }
                    .tag(3)
                    
                    // Page 4: Activity
                    HeroPageView(title: "How active are you?") {
                        VStack(spacing: NGSize.spacing) {
                            Button("1-2 days/week") {
                                viewModel.activityLevel = "1-2"
                            }
                            .buttonStyle(HeroSelectionButtonStyle(isSelected: viewModel.activityLevel == "1-2"))
                            
                            Button("3-4 days/week") {
                                viewModel.activityLevel = "3-4"
                            }
                            .buttonStyle(HeroSelectionButtonStyle(isSelected: viewModel.activityLevel == "3-4"))
                            
                            Button("5-6 days/week") {
                                viewModel.activityLevel = "5-6"
                            }
                            .buttonStyle(HeroSelectionButtonStyle(isSelected: viewModel.activityLevel == "5-6"))
                        }
                    }
                    .tag(4)
                    
                    // Page 5: Target
                    HeroPageView(title: "What's your goal?") {
                        VStack(spacing: NGSize.spacing) {
                            Button("Lose weight") {
                                viewModel.target = "lose"
                            }
                            .buttonStyle(HeroSelectionButtonStyle(isSelected: viewModel.target == "lose"))
                            
                            Button("Maintain weight") {
                                viewModel.target = "maintain"
                            }
                            .buttonStyle(HeroSelectionButtonStyle(isSelected: viewModel.target == "maintain"))
                            
                            Button("Gain muscle") {
                                viewModel.target = "gain"
                            }
                            .buttonStyle(HeroSelectionButtonStyle(isSelected: viewModel.target == "gain"))
                        }
                    }
                    .tag(5)
                    
                    // Page 6: Weekly Pace
                    HeroPageView(title: "Weekly pace goal?") {
                        VStack {
                            Text(String(format: "%.1f kg/week", viewModel.weeklyPaceKg))
                                .font(NGFont.titleXL)
                                .foregroundColor(.white)
                            
                            Slider(value: $viewModel.weeklyPaceKg, in: 0...2, step: 0.1)
                                .accentColor(.white)
                        }
                    }
                    .tag(6)
                    
                    // Page 7: Diet Type
                    HeroPageView(title: "Any dietary preferences?") {
                        VStack(spacing: NGSize.spacing) {
                            Button("None") {
                                viewModel.dietType = "none"
                            }
                            .buttonStyle(HeroSelectionButtonStyle(isSelected: viewModel.dietType == "none"))
                            
                            Button("Vegetarian") {
                                viewModel.dietType = "vegetarian"
                            }
                            .buttonStyle(HeroSelectionButtonStyle(isSelected: viewModel.dietType == "vegetarian"))
                            
                            Button("Vegan") {
                                viewModel.dietType = "vegan"
                            }
                            .buttonStyle(HeroSelectionButtonStyle(isSelected: viewModel.dietType == "vegan"))
                            
                            Button("Keto") {
                                viewModel.dietType = "keto"
                            }
                            .buttonStyle(HeroSelectionButtonStyle(isSelected: viewModel.dietType == "keto"))
                        }
                    }
                    .tag(7)
                    
                    // Page 8: Language (Final)
                    HeroPageView(title: "Choose your language") {
                        VStack(spacing: NGSize.spacing * 2) {
                            VStack(spacing: NGSize.spacing) {
                                Button("English") {
                                    viewModel.lang = "en"
                                }
                                .buttonStyle(HeroSelectionButtonStyle(isSelected: viewModel.lang == "en"))
                                
                                Button("Türkçe") {
                                    viewModel.lang = "tr"
                                }
                                .buttonStyle(HeroSelectionButtonStyle(isSelected: viewModel.lang == "tr"))
                                
                                Button("Español") {
                                    viewModel.lang = "es"
                                }
                                .buttonStyle(HeroSelectionButtonStyle(isSelected: viewModel.lang == "es"))
                            }
                            
                            // Finish Button
                            PrimaryButton(title: "Finish") {
                                Task {
                                    await viewModel.finish()
                                }
                            }
                            .disabled(viewModel.lang.isEmpty)
                        }
                    }
                    .tag(8)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .environmentObject(viewModel)
                .onAppear {
                    viewModel.setupDependencies(router: router)
                }
            }
        }
    }
}

// MARK: - Helper Views
struct HeroSelectionButtonStyle: ButtonStyle {
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(isSelected ? .white : Color.white.opacity(0.2))
            .foregroundColor(isSelected ? NGColor.primary : .white)
            .cornerRadius(NGSize.corner)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Navigation Extension for Onboarding Pages
extension HeroPageView {
    func withNavigation(viewModel: OnboardingViewModel, isLastPage: Bool = false, isValid: Bool = true) -> some View {
        VStack(spacing: NGSize.spacing * 2) {
            self
            
            if !isLastPage {
                PrimaryButton(title: "Next") {
                    viewModel.next()
                }
                .disabled(!isValid)
            }
        }
    }
}

#Preview {
    OnboardingView()
} 