//
//  Details.swift
//  FlavourFinder
//

import SwiftUI

struct Details: View {
    
    let recipe: Recipe
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        ZStack {
            
            // Background
            Color.darkBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // Header
                HStack {
                    
                    // Done Button
                    Button(action: { dismiss() }) {
                        Text("Done")
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
                    
                }
                .padding(.horizontal, 25)
                .padding(.vertical, 25)
                .background(Color.darkBackground)
                
                // Content
                ScrollView {
                    
                    VStack(alignment: .leading, spacing: 25) {
                        
                        // Recipe Image
                        AsyncImage(url: URL(string: recipe.imageUrl)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 250)
                                    .clipped()
                            } else {
                                Image(recipe.imageUrl)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 250)
                                    .clipped()
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 25) {
                            
                            // Preferences Used
                            if let prefs = recipe.preferences {
                                VStack(alignment: .leading, spacing: 10) {
                                    
                                    Text("Generation Preferences")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.neonBlue)
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        PreferenceRow(icon: "gauge", label: "Effort", value: prefs.getDisplayText(for: .effort))
                                        PreferenceRow(icon: "star", label: "Skill", value: prefs.getDisplayText(for: .skill))
                                        PreferenceRow(icon: "flame", label: "Calories", value: prefs.getDisplayText(for: .calorie))
                                        PreferenceRow(icon: "bolt", label: "Protein", value: prefs.getDisplayText(for: .protein))
                                        PreferenceRow(icon: "flame.fill", label: "Spice", value: prefs.getDisplayText(for: .spice))
                                    }
                                    
                                    .padding()
                                    .background(Color.cardBackground.opacity(0.5))
                                    .cornerRadius(10)
                                    
                                }
                                
                                Divider()
                                    .background(Color.gray.opacity(0.5))
                            }
                            
                            // Macros
                            VStack(alignment: .leading, spacing: 10) {
                                
                                Text("Nutrition")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.neonBlue)
                                
                                HStack(spacing: 25) {
                                    MacroDetails(label: "Calories", value: "\(recipe.macros.calories)")
                                    MacroDetails(label: "Protein", value: "\(recipe.macros.protein)g")
                                    MacroDetails(label: "Carbs", value: "\(recipe.macros.carbs)g")
                                    MacroDetails(label: "Fat", value: "\(recipe.macros.fat)g")
                                }
                                
                            }
                            
                            Divider()
                                .background(Color.gray.opacity(0.5))
                            
                            // Ingredients
                            VStack(alignment: .leading, spacing: 10) {
                                
                                Text("Ingredients")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.neonBlue)
                                
                                ForEach(Array(recipe.ingredients.enumerated()), id: \.offset) { _, ingredient in
                                    HStack(alignment: .top) {
                                        Text("•")
                                            .foregroundColor(.neonPink)
                                            .fontWeight(.bold)
                                        Text(ingredient)
                                            .foregroundColor(.white)
                                    }
                                    .font(.subheadline)
                                }
                                
                            }
                            
                            Divider()
                                .background(Color.gray.opacity(0.5))
                            
                            // Steps
                            VStack(alignment: .leading, spacing: 10) {
                                
                                Text("Instructions")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.neonBlue)
                                
                                ForEach(recipe.steps) { step in
                                    HStack(alignment: .top, spacing: 10) {
                                        Text("\(step.stepNumber)")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(.neonPink)
                                            .frame(width: 30)
                                        Text(step.instruction)
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                    }
                                }
                                
                            }
                            
                        }
                        .padding()
                    }
                }
            }
        }
    }
}

// Helper for Preference Row
struct PreferenceRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.neonPink)
                .frame(width: 20)
            Text(label)
                .foregroundColor(.gray)
                .font(.subheadline)
            Spacer()
            Text(value)
                .foregroundColor(.white)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}

// Helper for Macro Details
struct MacroDetails: View {
    
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .foregroundStyle(LinearGradient(colors: [.neonPink, .neonBlue],
                                              startPoint: .leading,
                                              endPoint: .trailing))
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}
