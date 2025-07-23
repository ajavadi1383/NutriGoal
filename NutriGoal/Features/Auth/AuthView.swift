import SwiftUI

struct AuthView: View {
    @StateObject private var viewModel: AuthViewModel
    
    init(router: AppRouter) {
        self._viewModel = StateObject(wrappedValue: AuthViewModel(router: router))
    }
    
    var body: some View {
        HeroBaseView {
            VStack(spacing: NGSize.spacing * 2) {
                Spacer()
                
                // Title
                Text("Welcome to NutriGoal")
                    .font(NGFont.titleXL)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Sign in or create your account")
                    .font(NGFont.bodyM)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                // Email/Password Form
                VStack(spacing: NGSize.spacing) {
                    // Email field
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(HeroTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .disabled(viewModel.isLoading)
                    
                    // Password field
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(HeroTextFieldStyle())
                        .disabled(viewModel.isLoading)
                    
                    // Auth Buttons
                    VStack(spacing: NGSize.spacing / 2) {
                        PrimaryButton(title: viewModel.isLoading ? "Processing..." : "Sign Up") {
                            Task {
                                await viewModel.signUpTapped()
                            }
                        }
                        .disabled(!viewModel.isFormValid || viewModel.isLoading)
                        
                        PrimaryButton(title: viewModel.isLoading ? "Processing..." : "Sign In") {
                            Task {
                                await viewModel.signInTapped()
                            }
                        }
                        .disabled(!viewModel.isFormValid || viewModel.isLoading)
                        .buttonStyle(SecondaryButtonStyle())
                    }
                }
                
                Spacer()
                
                // Skip for now
                Button("Skip for now") {
                    viewModel.skipTapped()
                }
                .foregroundColor(.white.opacity(0.7))
                .font(NGFont.bodyM)
                .disabled(viewModel.isLoading)
                
                Spacer()
            }
            .padding()
        }
        .overlay(
            Group {
                if viewModel.isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: NGSize.spacing) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                        
                        Text(viewModel.loadingMessage)
                            .foregroundColor(.white)
                            .font(NGFont.bodyM)
                    }
                }
            }
        )
        .alert("Authentication", isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}

// MARK: - Hero Text Field Style
struct HeroTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.2))
            .foregroundColor(.white)
            .cornerRadius(NGSize.corner)
            .overlay(
                RoundedRectangle(cornerRadius: NGSize.corner)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Secondary Button Style  
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(Color.white.opacity(0.2))
            .foregroundColor(.white)
            .cornerRadius(NGSize.corner)
            .overlay(
                RoundedRectangle(cornerRadius: NGSize.corner)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

#Preview {
    AuthView(router: AppRouter())
} 
 