//
//  Modifications.swift
//  FlavourFinder
//

import SwiftUI

struct Modifications: View {
    
    let recipe: Recipe
    let onModified: (Recipe) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var modification = ""
    @State private var isModifying = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        
        ZStack {
            
            // Background
            Color.darkBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // Header
                HStack {
                    
                    // Cancel Button
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .foregroundColor(.neonBlue)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    // Recipe Title
                    Text(recipe.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(LinearGradient(colors: [.neonBlue, .neonPink], startPoint: .leading, endPoint: .trailing))
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Invisible Button for Centering
                    Button(action: {}) {
                        Text("Cancel")
                            .foregroundColor(.clear)
                    }
                    .disabled(true)
                    
                }
                .padding(.horizontal, 25)
                .padding(.vertical, 25)
                .background(Color.darkBackground)
                
                // Content
                VStack(spacing: 25) {
                    
                    Spacer()
                    
                    // Input Header
                    Text("What would you like to change?")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    // Input Field
                    TextField("e.g., make it vegan, reduce cooking time", text: $modification, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .tint(.neonPink)
                    
                    // Modify Recipe Button
                    Button(action: modifyRecipe) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(LinearGradient(colors: [.neonBlue, .neonPink], startPoint: .leading, endPoint: .trailing))
                                .shadow(color: .neonPink.opacity(0.5), radius: 10)
                                .shadow(color: .neonBlue.opacity(0.5), radius: 10)
                            if isModifying {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Label("Modify Recipe", systemImage: "sparkles")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(height: 50)
                    }
                    .disabled(modification.isEmpty || isModifying)
                    .opacity(modification.isEmpty || isModifying ? 0.5 : 1.0)
                    .padding(.horizontal)
                    Spacer()
                }
            }
        }
        
        // Handle Errors
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        
    }
    
    // Modify Recipe
    private func modifyRecipe() {
        Task {
            
            isModifying = true
            
            do {
                
                // Request Modification from Backend
                var modifiedRecipe = try await NetworkService.shared.modifyRecipe(
                    recipeId: recipe.id,
                    modification: modification
                )
                
                // Preserve Original Preferences
                if let originalPrefs = recipe.preferences {
                    modifiedRecipe.preferences = originalPrefs
                }
                
                // Update Main UI
                await MainActor.run {
                    isModifying = false
                    onModified(modifiedRecipe)
                    dismiss()
                }
                
            } catch {
                
                // Handle Errors
                await MainActor.run {
                    isModifying = false
                    errorMessage = "Failed to modify recipe: \(error.localizedDescription)"
                    showError = true
                }
                
            }
        }
    }
}
