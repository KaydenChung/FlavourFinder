//
//  Preferences.swift
//  FlavourFinder
//

import SwiftUI

struct Preferences: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var preferencesManager = PreferencesManager.shared
    @State private var tempPreferences: UserPreferences
    
    let onGenerate: (UserPreferences) -> Void
    
    init(onGenerate: @escaping (UserPreferences) -> Void) {
        self.onGenerate = onGenerate
        _tempPreferences = State(initialValue: PreferencesManager.shared.preferences)
    }
    
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
                    
                    // Preferences Title
                    Text("Preferences")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(LinearGradient(colors: [.neonBlue, .neonPink], startPoint: .leading, endPoint: .trailing))
                    
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
                
                // Preferences Form
                Form {
                    
                    // Preference Information
                    Section {
                        Text("Adjust your preferences for this recipe generation.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .listRowBackground(Color.cardBackground)
                    
                    // Effort Preference
                    PreferenceSection(
                        title: "Effort Level",
                        subtitle: "How much time do you have?",
                        value: $tempPreferences.effortLevel,
                        labels: ["Quick", "Moderate", "Intricate"]
                    )
                    
                    // Skill Preference
                    PreferenceSection(
                        title: "Skill Level",
                        subtitle: "What is your cooking confidence?",
                        value: $tempPreferences.skillLevel,
                        labels: ["Beginner", "Intermediate", "Advanced"]
                    )
                    
                    // Calorie Preference
                    PreferenceSection(
                        title: "Calorie Consciousness",
                        subtitle: "How low-calorie do you want it?",
                        value: $tempPreferences.calorieConsciousness,
                        labels: ["Low", "Moderate", "High"]
                    )
                    
                    // Protein Preference
                    PreferenceSection(
                        title: "Protein Preference",
                        subtitle: "How much focus on protein?",
                        value: $tempPreferences.proteinPreference,
                        labels: ["Low", "Moderate", "High"]
                    )
                    
                    // Spice Preference
                    PreferenceSection(
                        title: "Spice Level",
                        subtitle: "How spicy should it be?",
                        value: $tempPreferences.spiceLevel,
                        labels: ["Not Spicy", "Mild", "Hot"]
                    )
                    
                    // Generate Recipe Button
                    Section {
                        Button(action: {
                            onGenerate(tempPreferences)
                            dismiss()
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(LinearGradient(colors: [.neonBlue, .neonPink], startPoint: .leading, endPoint: .trailing))
                                    .shadow(color: .neonPink.opacity(0.5), radius: 10)
                                    .shadow(color: .neonBlue.opacity(0.5), radius: 10)
                                Label("Generate Recipe", systemImage: "sparkles")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .frame(height: 50)
                        }
                        .buttonStyle(.plain)
                        .listRowInsets(EdgeInsets())
                    }
                    .listRowBackground(Color.clear)
                    
                }
                .scrollContentBackground(.hidden)
            }
        }
    }
}

#Preview {
    Preferences { _ in }
}
