import SwiftUI

struct HeroView: View {
    @StateObject private var viewModel: HeroViewModel
    
    init() {
        // TODO: Inject via Resolver
        let authManager = FirebaseAuthManager()
        self._viewModel = StateObject(wrappedValue: HeroViewModel(authManager: authManager))
    }
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [NGColor.primary, NGColor.secondary]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: NGSize.spacing * 2) {
                Spacer()
                
                // App icon placeholder
                Image(systemName: "flame.fill")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.white)
                
                // Tagline
                Text("Smarter tracking, no guilt.")
                    .font(NGFont.titleXL)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, NGSize.spacing)
                
                Spacer()
                
                // CTA Button
                PrimaryButton(title: "Start Your Journey") {
                    Task {
                        await viewModel.startTapped()
                    }
                }
                .padding(.horizontal, NGSize.spacing)
                .padding(.bottom, NGSize.spacing * 2)
            }
        }
    }
}

#Preview {
    HeroView()
} 