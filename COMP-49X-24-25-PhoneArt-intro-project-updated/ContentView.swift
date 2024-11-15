//
//  ContentView.swift
//  COMP-49X-24-25-PhoneArt-intro-project-updated
//
//  Created by Aditya Prakash on 11/14/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    // State variables. Will be more useful when implementing login logic.
    @State private var email = ""
    @State private var password = ""
    
    // Login Page for the application. 
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                    .frame(height: 175)
                
                welcomeHeader()
                emailField()
                passwordField()
                signInButton()
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }

    // The action function for the sign in button.
    private func handleLogin() {
        // Login logic will be implemented later
    }

    // The welcome header for the login page.
    private func welcomeHeader() -> some View {
        Text("Welcome!")
            .bold()
            .font(.title)
    }
    
    // The email field for the login page.
    private func emailField() -> some View {
        TextField("Email", text: $email)
            .textFieldStyle(.plain)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 4)
            )
            .padding(.horizontal, 40)
            .autocapitalization(.none)
    }
    
    // The password field for the login page.
    private func passwordField() -> some View {
        SecureField("Password", text: $password)
            .textFieldStyle(.plain)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 4)
            )
            .padding(.horizontal, 40)
            .autocapitalization(.none)
    }
    
    // The sign in button for the login page.
    private func signInButton() -> some View {
        Button(action: handleLogin) {
            Text("Sign In")
                .bold()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 0.0, green: 0.5, blue: 1.0))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(red: 0.0, green: 0.4, blue: 0.8), lineWidth: 8)
                )
                .cornerRadius(20)
        }
        .padding(.horizontal, 40)
       
    }
    
}

#Preview {
    ContentView()
}
