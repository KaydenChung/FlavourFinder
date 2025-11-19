//
//  ContentView.swift
//  FlavourFinder
//

import SwiftUI

struct ContentView: View {
    
    init() {}
    
    var body: some View {
        
        ZStack {
            
            // Background
            Color.darkBackground.ignoresSafeArea()
            
            // Navigation Bar
            TabView {
                
                // Home Page
                Home()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                
                // Saved Page
                Saved()
                    .tabItem {
                        Label("Saved", systemImage: "bookmark.fill")
                    }
                
                // Settings Page
                Settings()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                
            }
            
        }
        
    }
}

#Preview {
    ContentView()
}
