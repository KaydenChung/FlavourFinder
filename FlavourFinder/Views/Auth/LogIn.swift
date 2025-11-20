//
//  LogIn.swift
//  FlavourFinder
//

import SwiftUI

struct LogIn: View {
    
    @StateObject private var authManager = AuthManager.shared
    @Binding var isSignUp: Bool
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            // Email Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .fontWeight(.medium)
                
                TextField("", text: $email)
                    .textFieldStyle(.plain)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.neonBlue.opacity(0.3), lineWidth: 1)
                    )
            }
            
            // Password Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .fontWeight(.medium)
                
                SecureField("", text: $password)
                    .textFieldStyle(.plain)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.neonBlue.opacity(0.3), lineWidth: 1)
                    )
            }
            
            // Log In Button
            Button(action: logIn) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(
                            colors: [.neonBlue, .neonPink],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .shadow(color: .neonPink.opacity(0.5), radius: 10)
                        .shadow(color: .neonBlue.opacity(0.5), radius: 10)
                    
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Sign In")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                .frame(height: 55)
            }
            .disabled(isLoading || email.isEmpty || password.isEmpty)
            .opacity(email.isEmpty || password.isEmpty ? 0.5 : 1.0)
            .padding(.top, 10)
            
            // Sign Up Link
            Button(action: { isSignUp = true }) {
                HStack(spacing: 5) {
                    Text("Don't have an account?")
                        .foregroundColor(.gray)
                    Text("Sign Up")
                        .foregroundColor(.neonBlue)
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
            }
            .padding(.top, 5)
            
        }
        
        // Error Alert
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    // Log In Function
    private func logIn() {
        Task {
            isLoading = true
            
            do {
                try await authManager.signIn(email: email, password: password)
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
            await MainActor.run {
                isLoading = false
            }
        }
    }
}
