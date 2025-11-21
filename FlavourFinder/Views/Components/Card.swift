//
//  Card.swift
//  FlavourFinder
//

import SwiftUI

struct Card: View {
    
    let recipe: Recipe
    let onModified: (Recipe) -> Void
    @State private var showFullRecipe = false
    @State private var showModify = false
    @State private var isSaved = false
    @State private var isSaving = false
    @State private var showSaveError = false
    @State private var saveErrorMessage = ""

    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            // Recipe Image
            GeometryReader { geo in
                AsyncImage(url: URL(string: recipe.imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.darkBackground)
                            .overlay {
                                ProgressView()
                                    .tint(.neonPink)
                            }
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width, height: 250)
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
                .frame(width: geo.size.width, height: 250)
            }
            .frame(height: 250)
            
            // Recipe Details
            VStack(alignment: .leading, spacing: 15) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(recipe.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(LinearGradient(colors: [.neonBlue.opacity(0.5), .neonPink.opacity(0.5)], startPoint: .leading, endPoint: .trailing))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }

                // Recipe Title and Description
                Text(recipe.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(LinearGradient(colors: [.neonBlue, .neonPink], startPoint: .leading, endPoint: .trailing))
                Text(recipe.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)

                // Quick Stats
                HStack(spacing: 25) {
                    Label("\(recipe.cookTime) min", systemImage: "clock.fill")
                        .foregroundStyle(LinearGradient(colors: [.neonBlue, .neonPink], startPoint: .leading, endPoint: .trailing))
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Label("\(recipe.macros.calories) cal", systemImage: "flame.fill")
                        .foregroundStyle(LinearGradient(colors: [.neonBlue, .neonPink], startPoint: .leading, endPoint: .trailing))
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Label("\(recipe.macros.protein)g", systemImage: "bolt.fill")
                        .foregroundStyle(LinearGradient(colors: [.neonBlue, .neonPink], startPoint: .leading, endPoint: .trailing))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                // Action Buttons
                HStack(spacing: 10) {
                    
                    // Save Button
                    Button(action: saveRecipe) {
                        ZStack {
                            if isSaving {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Label(isSaved ? "Saved" : "Save", systemImage: isSaved ? "bookmark.fill" : "bookmark")
                            }
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }
                    .buttonStyle(.plain)
                    .background(isSaved ?
                        LinearGradient(colors: [.green.opacity(0.7)], startPoint: .leading, endPoint: .trailing) :
                        LinearGradient(colors: [Color.gray.opacity(0.5)], startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(isSaving || isSaved)
                    
                    // View Button
                    Button(action: { showFullRecipe = true }) {
                        Label("View", systemImage: "book.fill")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.plain)
                    .background(Color.gray.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    // Modify Button
                    Button(action: { showModify = true }) {
                        Label("Modify", systemImage: "pencil")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.plain)
                    .background(LinearGradient(colors: [.neonBlue, .neonPink], startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(color: .neonBlue.opacity(0.5), radius: 5)
                }
                
            }
            .padding(25)
        }
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .cornerRadius(25)
        .shadow(color: .black.opacity(0.5), radius: 25, y: 5)
        
        // Show Details View
        .sheet(isPresented: $showFullRecipe) {
            Details(recipe: recipe)
        }
        
        // Show Modifications View
        .sheet(isPresented: $showModify) {
            Modifications(recipe: recipe, onModified: { modifiedRecipe in
                onModified(modifiedRecipe)
            })
        }
        
        // Handle Errors
        .alert("Save Error", isPresented: $showSaveError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(saveErrorMessage)
        }
        
    }
    
    private func saveRecipe() {
        
        Task {
            
            isSaving = true
            
            do {
                try await NetworkService.shared.saveRecipe(recipe)
                await MainActor.run {
                    withAnimation(.spring(response: 0.3)) {
                        isSaved = true
                    }
                }
            } catch {
                await MainActor.run {
                    if error.localizedDescription.contains("already saved") {
                        isSaved = true
                    } else {
                        saveErrorMessage = "Failed to save recipe: \(error.localizedDescription)"
                        showSaveError = true
                    }
                }
            }
            
            await MainActor.run {
                isSaving = false
            }
            
        }
        
    }
    
}
