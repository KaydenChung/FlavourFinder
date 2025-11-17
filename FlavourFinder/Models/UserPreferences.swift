//
//  UserPreferences.swift
//  FlavourFinder
//

import SwiftUI
import Foundation
import Combine

// User Preferences Manager
class PreferencesManager: ObservableObject {
    
    static let shared = PreferencesManager()
    @Published var preferences: UserPreferences
    private let key = "userPreferences"
    
    private init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(UserPreferences.self, from: data) {
            self.preferences = decoded
        } else {
            self.preferences = UserPreferences()
        }
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}

// User Preferences
struct UserPreferences: Codable, Equatable {
    
    var effortLevel: Int = 2
    var skillLevel: Int = 2
    var calorieConsciousness: Int = 2
    var proteinPreference: Int = 2
    var spiceLevel: Int = 2
    enum CodingKeys: String, CodingKey {
        case effortLevel = "effort_level"
        case skillLevel = "skill_level"
        case calorieConsciousness = "calorie_consciousness"
        case proteinPreference = "protein_preference"
        case spiceLevel = "spice_level"
    }
    
    func toPromptString() -> String {
        
        let effort = ["quick & easy", "moderate effort", "intricate dish"][effortLevel - 1]
        let skill = ["beginner-friendly", "intermediate", "advanced"][skillLevel - 1]
        let calories = ["low-calorie", "moderate calories", "high-calorie"][calorieConsciousness - 1]
        let protein = ["low-protein", "moderate protein", "high-protein"][proteinPreference - 1]
        let spice = ["not spicy", "mildly spicy", "very spicy"][spiceLevel - 1]
        
        return """
        Effort: \(effort)
        Skill: \(skill)
        Calories: \(calories)
        Protein: \(protein)
        Spice: \(spice)
        """
    }
    
    func getDisplayText(for type: PreferenceType) -> String {
        switch type {
        case .effort:
            return ["Quick & Easy", "Moderate", "Intricate"][effortLevel - 1]
        case .skill:
            return ["Beginner", "Intermediate", "Advanced"][skillLevel - 1]
        case .calorie:
            return ["Low-Calorie", "Moderate", "High-Calorie"][calorieConsciousness - 1]
        case .protein:
            return ["Low-Protein", "Moderate", "High-Protein"][proteinPreference - 1]
        case .spice:
            return ["Not Spicy", "Mild", "Hot"][spiceLevel - 1]
        }
    }
}

enum PreferenceType {
    case effort, skill, calorie, protein, spice
}
