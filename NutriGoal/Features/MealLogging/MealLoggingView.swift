import SwiftUI
import PhotosUI

struct MealLoggingView: View {
    @StateObject private var viewModel = MealLoggingViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            HeroBaseView {
                VStack(spacing: NGSize.spacing * 2) {
                    // Photo Picker Section
                    VStack(spacing: NGSize.spacing) {
                        Text("Add Photo")
                            .font(NGFont.titleXL)
                            .foregroundColor(.white)
                        
                        PhotosPicker(
                            selection: $viewModel.selectedPhotoItem,
                            matching: .images
                        ) {
                            ZStack {
                                RoundedRectangle(cornerRadius: NGSize.corner)
                                    .fill(Color.white.opacity(0.2))
                                    .frame(height: 200)
                                
                                if let image = viewModel.selectedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 200)
                                        .clipped()
                                        .cornerRadius(NGSize.corner)
                                        .overlay(
                                            // AI Processing Overlay
                                            viewModel.isRecognizing ? 
                                            Color.black.opacity(0.7).cornerRadius(NGSize.corner) : nil
                                        )
                                } else {
                                    VStack {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white)
                                        Text("Tap to add photo")
                                            .foregroundColor(.white)
                                    }
                                }
                                
                                // AI Recognition Loading
                                if viewModel.isRecognizing {
                                    VStack {
                                        ProgressView()
                                            .tint(.white)
                                            .scaleEffect(1.2)
                                        
                                        Text("🤖 AI Analyzing Food...")
                                            .font(NGFont.bodyM)
                                            .foregroundColor(.white)
                                            .padding(.top, 8)
                                    }
                                }
                            }
                        }
                        .onChange(of: viewModel.selectedPhotoItem) { _ in
                            Task { await viewModel.loadImage() }
                        }
                        .disabled(viewModel.isRecognizing)
                    }
                    
                    // Form Fields
                    VStack(spacing: NGSize.spacing) {
                        HeroTextField("Meal name", text: $viewModel.name)
                            .disabled(viewModel.isRecognizing)
                        
                        HStack {
                            HeroTextField("Calories", text: $viewModel.caloriesText)
                                .keyboardType(.numberPad)
                                .disabled(viewModel.isRecognizing)
                            HeroTextField("Protein (g)", text: $viewModel.proteinText)
                                .keyboardType(.numberPad)
                                .disabled(viewModel.isRecognizing)
                        }
                        
                        HStack {
                            HeroTextField("Carbs (g)", text: $viewModel.carbsText)
                                .keyboardType(.numberPad)
                                .disabled(viewModel.isRecognizing)
                            HeroTextField("Fat (g)", text: $viewModel.fatText)
                                .keyboardType(.numberPad)
                                .disabled(viewModel.isRecognizing)
                        }
                    }
                    
                    // AI Recognition Status
                    if viewModel.recognitionComplete && !viewModel.name.isEmpty {
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .foregroundColor(.green)
                            Text("AI suggested nutrition values - feel free to edit!")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    // Save Button
                    PrimaryButton(title: viewModel.isSaving ? "Saving..." : "Save Meal") {
                        Task {
                            await viewModel.saveTapped()
                            dismiss()
                        }
                    }
                    .disabled(viewModel.isSaving || viewModel.isRecognizing || viewModel.name.isEmpty)
                }
                .padding(NGSize.spacing * 2)
            }
            .navigationTitle("Log Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white)
                        .disabled(viewModel.isRecognizing || viewModel.isSaving)
                }
            }
        }
    }
}

// MARK: - Custom TextField for Hero Style
struct HeroTextField: View {
    let placeholder: String
    @Binding var text: String
    
    init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }
    
    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .background(Color.white.opacity(0.2))
            .foregroundColor(.white)
            .cornerRadius(NGSize.corner)
            .accentColor(.white)
    }
}

#Preview {
    MealLoggingView()
} 