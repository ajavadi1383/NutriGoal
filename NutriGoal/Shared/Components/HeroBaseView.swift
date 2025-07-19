import SwiftUI

/// Hero-style base view with gradient background for design consistency across all screens
struct HeroBaseView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // Hero-style gradient background
            LinearGradient(
                gradient: Gradient(colors: [NGColor.primary, NGColor.secondary]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            content
        }
    }
}

/// Hero-style page component for onboarding and other screens
struct HeroPageView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: NGSize.spacing * 2) {
            Spacer()
            
            // Title with Hero-style white text
            Text(title)
                .font(NGFont.titleXL)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, NGSize.spacing * 2)
            
            // Content area
            content
                .padding(.horizontal, NGSize.spacing * 2)
            
            Spacer()
        }
    }
}

#Preview {
    HeroBaseView {
        HeroPageView(title: "Sample Title") {
            Text("Sample content")
                .foregroundColor(.white)
        }
    }
} 