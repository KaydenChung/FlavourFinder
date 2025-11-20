//
//  NetworkService.swift
//  FlavourFinder
//

import Foundation

// Network Error Types
enum NetworkError: Error {
    case invalidURL
    case decodingError
    case serverError(String)
}

// Network Service for Backend API Calls
class NetworkService {
    
    static let shared = NetworkService()
    private let baseURL = "http:localhost:8000" //"https://flavourfinder-5dkq.onrender.com"
    
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
    
    // Generate New Recipe
    func generateRecipe(preferences: UserPreferences, existingRecipes: [Recipe] = []) async throws -> Recipe {
        guard let url = URL(string: "\(baseURL)/recipes/generate") else {
            throw NetworkError.invalidURL
        }
        
        // Get Auth Token
        guard let token = AuthManager.shared.getAccessToken() else {
            throw NetworkError.serverError("Not authenticated")
        }
        
        // Create POST Request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Create Request Body
        let body = GenerateRecipeRequest(
            preferences: preferences,
            existingRecipes: existingRecipes.map { $0.title }
        )
        request.httpBody = try JSONEncoder().encode(body)
        
        // Send Request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Validate Server Response
        try validate(response)
        
        // Decode Recipe Response
        return try JSONDecoder().decode(Recipe.self, from: data)
    }
    
    // Modify Existing Recipe
    func modifyRecipe(recipe: Recipe, modification: String) async throws -> Recipe {
        guard let url = URL(string: "\(baseURL)/recipes/modify") else {
            throw NetworkError.invalidURL
        }
        
        // Get Auth Token
        guard let token = AuthManager.shared.getAccessToken() else {
            throw NetworkError.serverError("Not authenticated")
        }
        
        // Create POST Request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Create Request Body
        let body = ModifyRecipeRequest(originalRecipe: recipe, modification: modification)
        request.httpBody = try JSONEncoder().encode(body)
        
        // Send Request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Validate Server Response
        try validate(response)
        
        // Decode Recipe Response
        return try JSONDecoder().decode(Recipe.self, from: data)
        
    }
    
}
