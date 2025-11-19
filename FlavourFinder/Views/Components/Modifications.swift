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
                
                // Cancel Button
                HStack {
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .foregroundColor(.neonBlue)
                            .fontWeight(.medium)
                    }
                    Spacer()
                }
                .padding(.horizontal, 25)
                .padding(.vertical, 25)
                .background(Color.darkBackground)
                
                // Content
                VStack(spacing: 25) {
                    
                    Spacer()
                    
                    // Input Header
                    Text("What Modifications Would You Like?")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.neonBlue)
                    
                    // Input Field
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $modification)
                            .frame(minHeight: 100)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .foregroundColor(.neonPink)
                            .tint(.neonPink)
                            .padding(12)
                        if modification.isEmpty {
                            Text("e.g. Different ingredient, Less cook time")
                                .foregroundColor(.neonPink.opacity(0.5))
                                .padding(.horizontal, 15)
                                .padding(.vertical, 25)
                                .allowsHitTesting(false)
                        }
                    }
                    .background(Color.darkBackground)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.neonBlue.opacity(0.5), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
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
                    recipe: recipe,
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
