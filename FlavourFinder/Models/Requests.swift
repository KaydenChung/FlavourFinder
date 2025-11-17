//
//  Requests.swift
//  FlavourFinder
//

import SwiftUI
import Foundation

// Generate Recipe Request Model
struct GenerateRecipeRequest: Codable {
    let preferences: UserPreferences
    let existingRecipes: [String]?
    
    enum CodingKeys: String, CodingKey {
        case preferences
        case existingRecipes = "existing_recipes"
    }
}

// Modify Recipe Request Model
struct ModifyRecipeRequest: Codable {
    let recipeId: String
    let modification: String
    
    enum CodingKeys: String, CodingKey {
        case recipeId = "recipe_id"
        case modification
    }
}
