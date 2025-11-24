//
//  SignUp.swift
//  FlavourFinder
//

import SwiftUI

struct SignUp: View {
    
    @StateObject private var authManager = AuthManager.shared
    @Binding var isSignUp: Bool
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    
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
            
            // Confirm Password Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Confirm Password")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .fontWeight(.medium)
                
                SecureField("", text: $confirmPassword)
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
            
            // Password Validation
            if !password.isEmpty && password != confirmPassword {
                Text("Passwords do not match")
                    .font(.caption)
                    .foregroundColor(.neonPink)
            }
            
            // Sign Up Button
            Button(action: signUp) {
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
                        Text("Create Account")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                .frame(height: 55)
            }
            .disabled(isLoading || !isValid)
            .opacity(isValid ? 1.0 : 0.5)
            .padding(.top, 10)
            
            // Sign In Link
            Button(action: { isSignUp = false }) {
                HStack(spacing: 5) {
                    Text("Already have an account?")
                        .foregroundColor(.gray)
                    Text("Sign In")
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
        
        // Success Alert
        .alert("Account Created!", isPresented: $showSuccess) {
            Button("Sign In Now") {
                isSignUp = false
            }
        } message: {
            Text("Your account has been created! You can now sign in.")
        }
        
    }
    
    // Validation
    private var isValid: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= 6
    }
    
    // Sign Up Function
    private func signUp() {
        
        Task {
            
            isLoading = true
            
            do {
                try await authManager.signUp(email: email, password: password)
                await MainActor.run {
                    isLoading = false
                    showSuccess = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
            
        }
        
    }
    
}
