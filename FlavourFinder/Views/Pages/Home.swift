//
//  Home.swift
//  FlavourFinder
//

import SwiftUI

struct Home: View {
    
    @State private var recipes: [Recipe] = []
    @State private var isGenerating = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showPreferences = false
    
    var body: some View {
        
        ZStack {
            
            // Background
            Color.darkBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // Application Header
                HStack {
                    
                    // Application Title
                    Text("Flavour Finder")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(LinearGradient(colors: [.neonBlue, .neonPink], startPoint: .leading, endPoint: .trailing))
                    
                    Spacer()
                    
                    // Generate Recipe Button
                    Button(action: { showPreferences = true }) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.neonBlue, .neonPink], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 50, height: 50)
                            Image(systemName: "sparkles")
                                .foregroundColor(.white)
                                .font(.system(size: 25, weight: .bold))
                        }
                        .shadow(color: .neonPink.opacity(0.5), radius: 10)
                        .shadow(color: .neonBlue.opacity(0.5), radius: 10)
                    }
                    .buttonStyle(.plain)
                    .disabled(isGenerating)
                    
                }
                .padding(.horizontal, 25)
                .padding(.vertical, 25)
                .background(Color.darkBackground)
                
                // Scrollable Recipe List
                ScrollView {
                    VStack(spacing: 25) {
                        
                        // Empty State View
                        if recipes.isEmpty && !isGenerating {
                            VStack(spacing: 25) {
                                ZStack {
                                    Circle()
                                        .fill(LinearGradient(colors: [.neonBlue.opacity(0.3), .neonPink.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 150, height: 150)
                                        .blur(radius: 25)
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 75))
                                        .foregroundStyle(LinearGradient(colors: [.neonBlue, .neonPink], startPoint: .topLeading, endPoint: .bottomTrailing))
                                }
                                Text("No Recipes Yet!")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                Text("Tap the ✨ button to generate your first AI recipe")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.top, 100)
                        }
                        
                        // Display Recipe Cards
                        ForEach(recipes.indices, id: \.self) { index in
                            Card(recipe: recipes[index]) { modifiedRecipe in
                                recipes[index] = modifiedRecipe
                            }
                        }
                        
                    }
                    .padding()
                }
            }
            
            // Loading Overlay
            if isGenerating {
                ZStack {
                    Color.darkBackground.ignoresSafeArea()
                    VStack(spacing: 25) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.neonBlue)
                        Text("Generating delicious recipe...")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(25)
                    .background(Color.cardBackground)
                    .cornerRadius(25)
                    .shadow(color: .neonPink.opacity(0.3), radius: 25)
                }
            }
            
        }
        
        // Display Preferences View
        .sheet(isPresented: $showPreferences) {
            Preferences(onGenerate: generateRecipe)
        }
        
        // Handle Errors
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        
    }
    
    // Generate Recipe
    private func generateRecipe(preferences: UserPreferences) {
        Task {
            
            isGenerating = true
            
            do {
                
                // Request Recipe from Backend
                var recipe = try await NetworkService.shared.generateRecipe(
                    preferences: preferences,
                    existingRecipes: recipes
                )
                
                // Attach Recipe Preferences
                recipe.preferences = preferences
                
                // Update Main UI
                await MainActor.run {
                    recipes.insert(recipe, at: 0)
                    isGenerating = false
                }
                
            } catch {
                
                // Handle Errors
                await MainActor.run {
                    isGenerating = false
                    errorMessage = "Failed to generate recipe: \(error.localizedDescription)"
                    showError = true
                }
                
            }
        }
    }
}
