//
//  Settings.swift
//  FlavourFinder
//

import SwiftUI

struct Settings: View {
    
    @StateObject private var preferencesManager = PreferencesManager.shared
    @State private var showSaved = false
    
    var body: some View {
        
        ZStack {
            
            // Background
            Color.darkBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // Header
                HStack {
                    Text("Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(LinearGradient(colors: [.neonBlue, .neonPink], startPoint: .leading, endPoint: .trailing))
                    
                    Spacer()
                }
                .padding(.horizontal, 25)
                .padding(.vertical, 25)
                .background(Color.darkBackground)
                
                // Preferences Form
                Form {
                    
                    // Preference Information
                    Section {
                        Text("Set your default recipe preferences. These will be used when generating new recipes, but you can adjust them before each generation.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .listRowBackground(Color.cardBackground)
                    
                    // Effort Preference
                    PreferenceSection(
                        title: "Effort Level",
                        subtitle: "How much time do you have?",
                        value: $preferencesManager.preferences.effortLevel,
                        labels: ["Quick", "Moderate", "Intricate"]
                    )
                    
                    // Skill Preference
                    PreferenceSection(
                        title: "Skill Level",
                        subtitle: "What is your cooking confidence?",
                        value: $preferencesManager.preferences.skillLevel,
                        labels: ["Beginner", "Intermediate", "Advanced"]
                    )
                    
                    // Calorie Preference
                    PreferenceSection(
                        title: "Calorie Consciousness",
                        subtitle: "How low-calorie do you want it?",
                        value: $preferencesManager.preferences.calorieConsciousness,
                        labels: ["Low", "Moderate", "High"]
                    )
                    
                    // Protein Preference
                    PreferenceSection(
                        title: "Protein Preference",
                        subtitle: "How much focus on protein?",
                        value: $preferencesManager.preferences.proteinPreference,
                        labels: ["Low", "Moderate", "High"]
                    )
                    
                    // Spice Preference
                    PreferenceSection(
                        title: "Spice Level",
                        subtitle: "How spicy should it be?",
                        value: $preferencesManager.preferences.spiceLevel,
                        labels: ["Not Spicy", "Mild", "Hot"]
                    )
                    
                    // Save Preferences Button
                    Section {
                        Button(action: {
                            preferencesManager.save()
                            showSaved = true
                        }) {
                            HStack {
                                Spacer()
                                Text("Save Preferences")
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                        }
                        .tint(.neonBlue)
                    }
                    .listRowBackground(Color.cardBackground)
                    
                }
                .scrollContentBackground(.hidden)
                
            }
        }
        
        // Save Preferences Alert
        .alert("Saved!", isPresented: $showSaved) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your default preferences have been updated.")
        }
        
    }
}

// Helper Preference Section Component
struct PreferenceSection: View {
    
    let title: String
    let subtitle: String
    @Binding var value: Int
    let labels: [String]
    
    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 10) {
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack(spacing: 10) {
                    ForEach(1...3, id: \.self) { level in
                        Button(action: {
                            withAnimation(.spring(response: 0.5)) {
                                value = level
                            }
                        }) {
                            VStack(spacing: 10) {
                                Text("\(level)")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Text(labels[level - 1])
                                    .font(.caption2)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(value == level ?
                                        LinearGradient(colors: [.neonBlue, .neonPink],
                                                     startPoint: .topLeading,
                                                     endPoint: .bottomTrailing) :
                                        LinearGradient(colors: [Color.gray.opacity(0.5)],
                                                     startPoint: .top,
                                                     endPoint: .bottom))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(color: value == level ? .neonPink.opacity(0.5) : .clear,
                                   radius: 10)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.vertical, 5)
        } header: {
            Text(title)
                .foregroundColor(.neonBlue)
        }
        .listRowBackground(Color.cardBackground)
    }
}

#Preview {
    Settings()
}
