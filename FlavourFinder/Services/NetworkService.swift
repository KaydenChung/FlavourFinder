//
//  NetworkService.swift
//  FlavourFinder
//

import Foundation

// Error Types
enum NetworkError: Error {
    case invalidURL
    case decodingError
    case serverError(String)
    case notAuthenticated
}

class NetworkService {
    
    static let shared = NetworkService()
    private let baseURL = "https://flavourfinder-5dkq.onrender.com"
    
    private init() {}
    
    // Validate Server HTTP Response
    private func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.serverError("Invalid response")
        }
        guard http.statusCode == 200 else {
            throw NetworkError.serverError("Server returned status code: \(http.statusCode)")
        }
    }
    
    // Creates Request with Auth Tokens
    private func authenticatedRequest(url: URL) throws -> URLRequest {
        guard let token = AuthManager.shared.getAccessToken() else {
            throw NetworkError.notAuthenticated
        }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    // Generate Recipe
    func generateRecipe(preferences: UserPreferences, existingRecipes: [Recipe] = []) async throws -> Recipe {
        guard let url = URL(string: "\(baseURL)/recipes/generate") else {
            throw NetworkError.invalidURL
        }
        
        var request = try authenticatedRequest(url: url)
        request.httpMethod = "POST"
        
        let body = GenerateRecipeRequest(
            preferences: preferences,
            existingRecipes: existingRecipes.map { $0.title }
        )
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response)
        
        return try JSONDecoder().decode(Recipe.self, from: data)
    }
    
    // Modify Recipe
    func modifyRecipe(recipe: Recipe, modification: String) async throws -> Recipe {
        guard let url = URL(string: "\(baseURL)/recipes/modify") else {
            throw NetworkError.invalidURL
        }
        
        var request = try authenticatedRequest(url: url)
        request.httpMethod = "POST"
        
        let body = ModifyRecipeRequest(originalRecipe: recipe, modification: modification)
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response)
        
        return try JSONDecoder().decode(Recipe.self, from: data)
    }
    
    // Save a Recipe
    func saveRecipe(_ recipe: Recipe) async throws {
        guard let url = URL(string: "\(baseURL)/recipes/save") else {
            throw NetworkError.invalidURL
        }
        
        var request = try authenticatedRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(recipe)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        try validate(response)
    }
    
    // Unsave a Recipe
    func unsaveRecipe(recipeId: String) async throws {
        guard let url = URL(string: "\(baseURL)/recipes/save/\(recipeId)") else {
            throw NetworkError.invalidURL
        }
        
        var request = try authenticatedRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        try validate(response)
    }
    
    // Get Saved Recipes
    func getSavedRecipes() async throws -> [Recipe] {
        guard let url = URL(string: "\(baseURL)/recipes/saved") else {
            throw NetworkError.invalidURL
        }
        
        var request = try authenticatedRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response)
        
        let result = try JSONDecoder().decode(SavedRecipesResponse.self, from: data)
        return result.recipes.compactMap { $0.recipeData }
    }
    
    // Get User Preferences
    func getPreferences() async throws -> UserPreferences {
        guard let url = URL(string: "\(baseURL)/preferences") else {
            throw NetworkError.invalidURL
        }
        
        var request = try authenticatedRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response)
        
        return try JSONDecoder().decode(UserPreferences.self, from: data)
    }
    
    // Update User Preferences
    func updatePreferences(_ preferences: UserPreferences) async throws -> UserPreferences {
        guard let url = URL(string: "\(baseURL)/preferences") else {
            throw NetworkError.invalidURL
        }
        
        var request = try authenticatedRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = try JSONEncoder().encode(preferences)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response)
        
        return try JSONDecoder().decode(UserPreferences.self, from: data)
    }
}

// Saved Recipe Response Model
struct SavedRecipesResponse: Codable {
    let recipes: [SavedRecipeItem]
}

// Saved Recipe Item
struct SavedRecipeItem: Codable {
    
    let id: String
    let userId: String
    let recipeId: String
    let recipeData: Recipe?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case recipeId = "recipe_id"
        case recipeData = "recipe_data"
        case createdAt = "created_at"
    }
}
