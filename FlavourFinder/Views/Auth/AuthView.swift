//
//  Auth.swift
//  FlavourFinder
//

import SwiftUI

struct Auth: View {
    
    @StateObject private var authManager = AuthManager.shared
    @State private var isSignUp = false
    
    var body: some View {
        
        ZStack {
            
            // Background
            Color.darkBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                Spacer()
                
                // App Branding
                VStack(spacing: 20) {
                    
                    // App Icon
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [.neonBlue.opacity(0.3), .neonPink.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 120, height: 120)
                            .blur(radius: 20)
                        Image(systemName: "sparkles")
                            .font(.system(size: 60))
                            .foregroundStyle(LinearGradient(
                                colors: [.neonBlue, .neonPink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                    }
                    
                    // App Title
                    Text("Flavour Finder")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundStyle(LinearGradient(
                            colors: [.neonBlue, .neonPink],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                    Text("AI-Powered Recipe Assistant")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                }
                .padding(.bottom, 50)
                
                // Auth Form
                if isSignUp {
                    SignUp(isSignUp: $isSignUp)
                } else {
                    LogIn(isSignUp: $isSignUp)
                }
                
                Spacer()
                
            }
            .padding(.horizontal, 25)
            
        }
    }
}

#Preview {
    Auth()
}
