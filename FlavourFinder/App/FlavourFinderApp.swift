//
//  FlavourFinderApp.swift
//  FlavourFinder
//

import SwiftUI

@main
struct FlavourFinderApp: App {
    
    @StateObject private var authManager = AuthManager.shared
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    ContentView()
                } else {
                    Auth()
                }
            }
        }
    }
}
