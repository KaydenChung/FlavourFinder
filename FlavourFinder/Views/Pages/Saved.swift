//
//  Saved.swift
//  FlavourFinder
//

import SwiftUI

struct Saved: View {
    
    @State private var savedRecipes: [Recipe] = []
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        
        ZStack {
            
            Color.darkBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // Header
                HStack {
                    Text("Saved")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(LinearGradient(colors: [.neonBlue, .neonPink], startPoint: .leading, endPoint: .trailing))
                    Spacer()
                    
                    // Refresh Button
                    Button(action: { Task { await loadSavedRecipes() } }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.neonBlue)
                    }
                    .disabled(isLoading)
                }
                .padding(.horizontal, 25)
                .padding(.vertical, 25)
                .background(Color.darkBackground)
                
                // Content
                if isLoading && savedRecipes.isEmpty {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.neonBlue)
                    Spacer()
                } else if savedRecipes.isEmpty {
                    ScrollView {
                        emptyStateView
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 25) {
                            ForEach(savedRecipes) { recipe in
                                SavedCard(recipe: recipe, onUnsave: { unsavedRecipe in
                                    withAnimation {
                                        savedRecipes.removeAll { $0.id == unsavedRecipe.id }
                                    }
                                })
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .task {
            await loadSavedRecipes()
        }
        
        // Handle Errors
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        
    }
    
    // Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 25) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.neonBlue.opacity(0.5), .neonPink.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 150, height: 150)
                    .blur(radius: 25)
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 75))
                    .foregroundStyle(LinearGradient(colors: [.neonBlue, .neonPink], startPoint: .topLeading, endPoint: .bottomTrailing))
            }
            Text("No Saved Recipes")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            Text("Saved recipes will appear here.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 110)
    }
    
    // Load Saved Recipes
    private func loadSavedRecipes() async {
        isLoading = true
        do {
            savedRecipes = try await NetworkService.shared.getSavedRecipes()
        } catch is CancellationError {
            // Ignore Cancellation Error
        } catch {
            
            // Handle Errors
            errorMessage = "Failed to Load Saved Recipes: \(error.localizedDescription)"
            showError = true
            
        }
        isLoading = false
    }
    
}

// Saved Recipe Card
struct SavedCard: View {
    
    let recipe: Recipe
    let onUnsave: (Recipe) -> Void
    @State private var showFullRecipe = false
    @State private var isUnsaving = false
    @State private var showUnsaveConfirm = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // Recipe Image
            GeometryReader { geo in
                AsyncImage(url: URL(string: recipe.imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.darkBackground)
                            .overlay { ProgressView().tint(.neonPink) }
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width, height: 200)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(Color.cardBackground)
                            .overlay {
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                            }
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: geo.size.width, height: 200)
            }
            .frame(height: 200)
            
            // Recipe Details
            VStack(alignment: .leading, spacing: 10) {
                
                // Recipe Title and Description
                Text(recipe.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(LinearGradient(colors: [.neonBlue, .neonPink], startPoint: .leading, endPoint: .trailing))
                Text(recipe.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                // Quick Stats
                HStack(spacing: 20) {
                    Label("\(recipe.cookTime) min", systemImage: "clock.fill")
                    Label("\(recipe.macros.calories) cal", systemImage: "flame.fill")
                }
                .font(.caption)
                .foregroundStyle(LinearGradient(colors: [.neonBlue, .neonPink], startPoint: .leading, endPoint: .trailing))
                
                // Action Buttons
                HStack(spacing: 10) {
                    
                    // View Button
                    Button(action: { showFullRecipe = true }) {
                        Label("View", systemImage: "book.fill")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.plain)
                    .background(LinearGradient(colors: [.neonBlue, .neonPink], startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    // Unsave Button
                    Button(action: { showUnsaveConfirm = true }) {
                        ZStack {
                            if isUnsaving {
                                ProgressView().tint(.white)
                            } else {
                                Label("Remove", systemImage: "bookmark.slash.fill")
                            }
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }
                    .buttonStyle(.plain)
                    .background(Color.red.opacity(0.75))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(isUnsaving)
                    
                }
                
            }
            .padding(25)
        }
        .background(Color.cardBackground)
        .cornerRadius(25)
        .shadow(color: .black.opacity(0.5), radius: 25, y: 10)
        
        // Show Details View
        .sheet(isPresented: $showFullRecipe) {
            Details(recipe: recipe)
        }
        
        // Handle Errors
        .alert("Remove Recipe?", isPresented: $showUnsaveConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Remove", role: .destructive) { unsaveRecipe() }
        } message: {
            Text("This will remove \"\(recipe.title)\" from your saved recipes.")
        }
        
    }
    
    // Unsave Recipe
    private func unsaveRecipe() {
        Task {
            isUnsaving = true
            do {
                try await NetworkService.shared.unsaveRecipe(recipeId: recipe.id)
                await MainActor.run {
                    onUnsave(recipe)
                }
            } catch {
                print("Failed to Unsave: \(error)")
            }
            await MainActor.run {
                isUnsaving = false
            }
        }
    }
    
}
