//
//  Saved.swift
//  FlavourFinder
//

import SwiftUI

struct Saved: View {
    
    var body: some View {
        
        ZStack {
            
            // Background
            Color.darkBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // Header
                HStack {
                    Text("Saved")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(LinearGradient(colors: [.neonBlue, .neonPink], startPoint: .leading, endPoint: .trailing))
                    Spacer()
                }
                .padding(.horizontal, 25)
                .padding(.vertical, 25)
                .background(Color.darkBackground)
                
                // Scrollable Recipe List
                ScrollView {
                    VStack(spacing: 25) {
                        
                        // Empty State View
                        VStack(spacing: 25) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: [.neonBlue.opacity(0.3), .neonPink.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 150, height: 150)
                                    .blur(radius: 25)
                                Image(systemName: "bookmark.fill")
                                    .font(.system(size: 75))
                                    .foregroundStyle(LinearGradient(colors: [.neonBlue, .neonPink], startPoint: .topLeading, endPoint: .bottomTrailing))
                            }
                            Text("Saved Recipes")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Text("Your saved recipes will appear here")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 110)
                    }
                    .padding()
                }
            }
        }
    }
}
