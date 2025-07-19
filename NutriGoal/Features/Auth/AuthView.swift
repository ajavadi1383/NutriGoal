import SwiftUI

struct AuthView: View {
    @StateObject private var viewModel: AuthViewModel
    
    init(router: AppRouter) {
        // TODO: Inject via Resolver
        let authService = FirebaseAuthServiceImpl()
        self._viewModel = StateObject(wrappedValue: AuthViewModel(authService: authService, router: router))
    }
    
    var body: some View {
        VStack(spacing: NGSize.spacing * 2) {
            Spacer()
            
            // App icon and title
            VStack(spacing: NGSize.spacing) {
                Image(systemName: "flame.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(NGColor.primary)
                
                Text("Welcome to NutriGoal")
                    .font(NGFont.titleXL)
                    .foregroundColor(NGColor.gray6)
            }
            
            Spacer()
            
            // Auth form
            VStack(spacing: NGSize.spacing) {
                // Segmented control
                Picker("Auth Mode", selection: $viewModel.isSignUpMode) {
                    Text("Log In").tag(false)
                    Text("Sign Up").tag(true)
                }
                .pickerStyle(.segmented)
                .onChange(of: viewModel.isSignUpMode) { _ in
                    viewModel.toggleMode()
                }
                
                // Email field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(NGFont.bodyM)
                        .foregroundColor(NGColor.gray6)
                    
                    TextField("Enter your email", text: $viewModel.email)
                        .textFieldStyle(CustomTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                // Password field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(NGFont.bodyM)
                        .foregroundColor(NGColor.gray6)
                    
                    SecureField("Enter your password", text: $viewModel.password)
                        .textFieldStyle(CustomTextFieldStyle())
                }
                
                // Error message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(NGFont.bodyM)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
                
                // Continue button
                PrimaryButton(title: "Continue") {
                    Task {
                        await viewModel.submit()
                    }
                }
                .disabled(!viewModel.isFormValid || viewModel.isLoading)
                .overlay(
                    Group {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                    }
                )
                .padding(.top, NGSize.spacing)
            }
            .padding(.horizontal, NGSize.spacing)
            
            Spacer()
        }
        .background(NGColor.gray1)
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(NGSize.spacing)
            .background(Color.white)
            .cornerRadius(NGSize.corner)
            .overlay(
                RoundedRectangle(cornerRadius: NGSize.corner)
                    .stroke(NGColor.gray3, lineWidth: 1)
            )
    }
}

#Preview {
    AuthView(router: AppRouter())
} 
