import SwiftUI
import AuthenticationServices

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
                Text("Welcome Back")
                    .font(NGFont.titleXL)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                // Email/Password Form
                VStack(spacing: NGSize.spacing) {
                    // Email field
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(HeroTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    // Password field
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(HeroTextFieldStyle())
                    
                    // Email Auth Buttons
                    HStack(spacing: NGSize.spacing) {
                        PrimaryButton(title: "Sign In") {
                            Task {
                                await viewModel.signInTapped()
                            }
                        }
                        .disabled(!viewModel.isFormValid || viewModel.isLoading)
                        
                        PrimaryButton(title: "Sign Up") {
                            Task {
                                await viewModel.signUpTapped()
                            }
                        }
                        .disabled(!viewModel.isFormValid || viewModel.isLoading)
                    }
                }
                
                // Divider
                HStack {
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 1)
                    
                    Text("or")
                        .foregroundColor(.white.opacity(0.7))
                        .font(NGFont.bodyM)
                    
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 1)
                }
                .padding(.vertical, NGSize.spacing)
                
                // Apple Sign-In
                SignInWithAppleButton(
                    onRequest: { request in
                        // Configure the request if needed
                    },
                    onCompletion: { result in
                        Task {
                            await viewModel.appleTapped()
                        }
                    }
                )
                .signInWithAppleButtonStyle(.white)
                .frame(height: 48)
                .cornerRadius(NGSize.corner)
                
                Spacer()
                
                // Skip for now
                Button("Skip for now") {
                    viewModel.skipTapped()
                }
                .foregroundColor(.white.opacity(0.7))
                .font(NGFont.bodyM)
                
                Spacer()
            }
            .padding()
        }
        .overlay(
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                }
            }
        )
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

#Preview {
    AuthView(router: AppRouter())
} 
