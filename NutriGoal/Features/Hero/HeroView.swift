import SwiftUI

struct HeroView: View {
    @StateObject private var viewModel: HeroViewModel
    
    init(authManager: AuthManager, router: Router? = nil) {
        self._viewModel = StateObject(wrappedValue: HeroViewModel(authManager: authManager, router: router))
    }
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [NGColor.primary, NGColor.secondary]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: NGSize.spacingXL) {
                Spacer()
                
                // App icon placeholder
                Image(systemName: "heart.circle.fill")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                
                VStack(spacing: NGSize.spacingM) {
                    // Main headline
                    Text("Smarter tracking, no guilt.")
                        .font(NGFont.titleXL)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    // Subtitle
                    Text("AI-powered nutrition guidance that adapts to your lifestyle")
                        .font(NGFont.bodyL)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, NGSize.spacingL)
                }
                
                Spacer()
                
                // CTA Button
                VStack(spacing: NGSize.spacingM) {
                    PrimaryButton(title: "Start Your Journey") {
                        Task {
                            await viewModel.startTapped()
                        }
                    }
                    .disabled(viewModel.isLoading)
                    .overlay(
                        Group {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                        }
                    )
                    
                    // Trust indicators
                    HStack(spacing: NGSize.spacingS) {
                        Label("Free trial", systemImage: "checkmark.circle.fill")
                        
                        Spacer()
                        
                        Label("No ads", systemImage: "checkmark.circle.fill")
                        
                        Spacer()
                        
                        Label("Privacy first", systemImage: "checkmark.circle.fill")
                    }
                    .font(NGFont.caption)
                    .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, NGSize.spacingL)
                .padding(.bottom, NGSize.spacingXL)
            }
            .frame(maxHeight: .infinity, alignment: .center)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("Try Again") {
                Task {
                    await viewModel.startTapped()
                }
            }
            Button("Cancel", role: .cancel) {
                viewModel.dismissError()
            }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

#Preview {
    HeroView(authManager: FirebaseAuthManager())
        .preferredColorScheme(.light)
} 