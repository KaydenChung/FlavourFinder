//
//  Settings.swift
//  FlavourFinder
//

import SwiftUI

struct Settings: View {
    
    @StateObject private var preferencesManager = PreferencesManager.shared
    @StateObject private var authManager = AuthManager.shared
    @State private var showSaved = false
    @State private var showLogoutConfirm = false
    @State private var isLoggingOut = false
    @State private var isLoading = false
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    
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
                    
                    // Logout Button
                    Button(action: { showLogoutConfirm = true }) {
                        ZStack {
                            Circle()
                                .fill(Color.red.opacity(0.2))
                                .frame(width: 40, height: 40)
                            
                            if isLoggingOut {
                                ProgressView()
                                    .tint(.red)
                            } else {
                                Image(systemName: "arrow.right.square.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 20))
                            }
                        }
                    }
                    .disabled(isLoggingOut)
                    
                }
                .padding(.horizontal, 25)
                .padding(.vertical, 25)
                .background(Color.darkBackground)
                
                if isLoading {
                    Spacer()
                    VStack(spacing: 15) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.neonBlue)
                        Text("Loading preferences...")
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    
                    // Preferences Form
                    Form {
                        
                        // Sync Status
                        Section {
                            HStack {
                                Image(systemName: "cloud.fill")
                                    .foregroundColor(.neonBlue)
                                Text("Preferences sync with your account")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
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
                            Button(action: savePreferences) {
                                HStack {
                                    Spacer()
                                    if isSaving {
                                        ProgressView()
                                            .tint(.neonBlue)
                                    } else {
                                        Text("Save Preferences")
                                            .fontWeight(.semibold)
                                    }
                                    Spacer()
                                }
                            }
                            .tint(.neonBlue)
                            .disabled(isSaving)
                        }
                        .listRowBackground(Color.cardBackground)
                        
                    }
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .task {
            await loadPreferences()
        }
        
        // Handle Errors
        .alert("Saved!", isPresented: $showSaved) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your preferences have been synced to your account.")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .alert("Log Out", isPresented: $showLogoutConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Log Out", role: .destructive) { logout() }
        } message: {
            Text("Are you sure you want to log out?")
        }
        
    }
    
    // Load User Preferences
    private func loadPreferences() async {
        isLoading = true
        do {
            let serverPrefs = try await NetworkService.shared.getPreferences()
            await MainActor.run {
                preferencesManager.preferences = serverPrefs
                preferencesManager.save()
            }
        } catch {
            print("Failed to load server preferences, using local: \(error)")
        }
        await MainActor.run {
            isLoading = false
        }
    }
    
    // Save User Preferences
    private func savePreferences() {
        Task {
            isSaving = true
            do {
                let updatedPrefs = try await NetworkService.shared.updatePreferences(preferencesManager.preferences)
                await MainActor.run {
                    preferencesManager.preferences = updatedPrefs
                    preferencesManager.save() // Also save locally
                    showSaved = true
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to save preferences: \(error.localizedDescription)"
                    showError = true
                }
            }
            await MainActor.run {
                isSaving = false
            }
        }
    }
    
    // Log Out
    private func logout() {
        Task {
            isLoggingOut = true
            do {
                try await authManager.signOut()
            } catch {
                print("Error logging out: \(error)")
            }
            await MainActor.run {
                isLoggingOut = false
            }
        }
    }
    
}

// PreferenceSection Component
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
                                        LinearGradient(colors: [.neonBlue, .neonPink], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                        LinearGradient(colors: [Color.gray.opacity(0.5)], startPoint: .top, endPoint: .bottom))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(color: value == level ? .neonPink.opacity(0.5) : .clear,
                                   radius: 10)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.vertical, 10)
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
