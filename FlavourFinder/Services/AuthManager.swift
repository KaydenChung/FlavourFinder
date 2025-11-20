//
//  AuthManager.swift
//  FlavourFinder
//

import Foundation
import SwiftUI
import Combine
import Supabase

// Authentication Manager
@MainActor
class AuthManager: ObservableObject {
    
    static let shared = AuthManager()
    
    @Published var session: Session?
    @Published var isAuthenticated = false
    
    // Supabase Client
    let client: SupabaseClient
    
    private init() {
        
        // Initialize Supabase Client
        self.client = SupabaseClient(
            supabaseURL: URL(string: "https://tqnkpfftsexqnnnwqpyu.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRxbmtwZmZ0c2V4cW5ubndxcHl1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM1MjExODIsImV4cCI6MjA3OTA5NzE4Mn0.JvkCxU3RDtPJNh7G2e3sRon4tuQW3frCmFi_S6y0Kx0"
        )
        
        // Check for Existing Session
        Task {
            await checkSession()
        }
        
        // Listen for Auth State Changes
        Task {
            for await (event, session) in client.auth.authStateChanges {
                self.session = session
                self.isAuthenticated = session != nil
            }
        }
    }
    
    // Check for Existing Session
    func checkSession() async {
        do {
            let currentSession = try await client.auth.session
            self.session = currentSession
            self.isAuthenticated = true
        } catch {
            self.session = nil
            self.isAuthenticated = false
        }
    }
    
    // Sign Up with Email
    func signUp(email: String, password: String) async throws {
        let authResponse = try await client.auth.signUp(
            email: email,
            password: password
        )
        self.session = authResponse.session
        self.isAuthenticated = authResponse.session != nil
    }
    
    // Sign In with Email
    func signIn(email: String, password: String) async throws {
        let authResponse = try await client.auth.signIn(
            email: email,
            password: password
        )
        self.session = authResponse
        self.isAuthenticated = true
    }
    
    // Sign Out
    func signOut() async throws {
        try await client.auth.signOut()
        self.session = nil
        self.isAuthenticated = false
    }
    
    // Get Access Token
    func getAccessToken() -> String? {
        return session?.accessToken
    }
    
}
