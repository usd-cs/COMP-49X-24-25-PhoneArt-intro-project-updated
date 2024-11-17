//
//  ContentView.swift
//  COMP-49X-24-25-PhoneArt-intro-project-updated
//
//  Created by Aditya Prakash on 11/17/24.
//

import SwiftUI

// ContentView is the main view of the application. It will include the login page.
struct ContentView: View {
   @State private var email = ""
   @State private var password = ""
   @State private var showingLoginError = false
  
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
  
   // The sign in button(s) for the login page. Also includes the guest sign in button.
   private func signInButton() -> some View {
       VStack(spacing: 20) {
           Button(action: {}) {
               Text("Sign In")
                   // Formatting the button.
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
          
           Button(action: {
               // Guest login functionality will be implemented here
           }) {
               Text("Sign in as Guest")
                   .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
           }
       }
       .padding(.horizontal, 40)
       
   }
}

#Preview {
    ContentView()
}
