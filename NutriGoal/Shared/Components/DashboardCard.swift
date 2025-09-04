import SwiftUI

/// Dashboard card component for displaying stats with icon, value, and target
struct DashboardCard: View {
    let title: String
    let value: String
    let target: String
    let icon: String
    
    var body: some View {
        VStack(spacing: NGSize.spacing / 2) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(NGColor.primary)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(NGFont.bodyS)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(value)
                    .font(NGFont.titleM)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                
                Text("of \(target)")
                    .font(NGFont.bodyXS)
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(NGSize.corner)
        .frame(height: 100)
    }
}

#Preview {
    HStack {
        DashboardCard(title: "Calories", value: "1,247", target: "2,100", icon: "flame.fill")
        DashboardCard(title: "Protein", value: "45g", target: "140g", icon: "leaf.fill")
    }
    .padding()
    .background(LinearGradient(colors: [NGColor.primary, NGColor.secondary], startPoint: .top, endPoint: .bottom))
}
