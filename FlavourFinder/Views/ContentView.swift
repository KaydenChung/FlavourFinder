//
//  ContentView.swift
//  FlavourFinder
//

import SwiftUI

struct ContentView: View {
    
    init() {
        
//        // Configure Tab Bar Appearance
//        let appearance = UITabBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = UIColor(Color.cardBackground)
//        
//        // Selected Item Colour
//        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.neonBlue)
//        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
//            .foregroundColor: UIColor(Color.neonBlue)
//        ]
//        
//        // Unselected Item Color
//        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
//        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
//            .foregroundColor: UIColor.gray
//        ]
        
    }
    
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
