//
//  Recipe.swift
//  FlavourFinder
//

import SwiftUI
import Foundation

// Nutritional Information
struct Macros: Codable {
    let calories: Int
    let protein: Int
    let carbs: Int
    let fat: Int
}

// Cooking Step
struct RecipeStep: Codable, Identifiable {
    var id: String { "\(stepNumber)" }
    let stepNumber: Int
    let instruction: String
    enum CodingKeys: String, CodingKey {
        case stepNumber = "step_number"
        case instruction
    }
}

// Recipe Model
struct Recipe: Identifiable, Codable {
    
    let id: String
    let imageUrl: String
    let title: String
    let description: String
    let cookTime: Int
    let tags: [String]
    let ingredients: [String]
    let steps: [RecipeStep]
    let macros: Macros
    var preferences: UserPreferences?
    
    enum CodingKeys: String, CodingKey {
        case id
        case imageUrl = "image_url"
        case title
        case description
        case cookTime = "cook_time"
        case tags
        case ingredients
        case steps
        case macros
        case preferences
    }
}
