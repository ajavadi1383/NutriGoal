import SwiftUI

/// Primary action button with filled accent color background and rounded corners
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    
    init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(NGFont.bodyM)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(NGColor.primary)
                .cornerRadius(NGSize.corner)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Get Started") {
            print("Button tapped")
        }
        
        PrimaryButton(title: "Continue") {
            print("Continue tapped")
        }
    }
    .padding()
} 