//
//  ContentView.swift
//  COMP-49X-24-25-PhoneArt-intro-project-updated
//
//  Created by Aditya Prakash on 11/17/24.
//


import SwiftUI


// ContentView is the main view of the application. It will include the login page.
struct ContentView: View {
  @StateObject private var userViewModel = UserViewModel()
  @State private var email = ""
  @State private var password = ""
  @State private var showingLoginError = false
  @State private var showingLoginSuccess = false
  @State private var isAuthenticated = false
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
          .fullScreenCover(isPresented: $isAuthenticated) {
                       PostView(isAuthenticated: $isAuthenticated)
                           .navigationViewStyle(StackNavigationViewStyle())
         }
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
          Button(action: {
              Task {
                  do {
                      try await userViewModel.signIn(email: email, password: password)
                      showingLoginSuccess = true
                      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                          isAuthenticated = true
                      // Handle successful login (e.g., navigate to main app view)
                  } catch {
                      showingLoginError = true
                  }
              }
          }) {
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
              isAuthenticated = true
              // Enable guest login by directly setting authenticated to true
          }) {
              Text("Sign in as Guest")
                  .foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
          }
      }
      .padding(.horizontal, 40)
      // Alert that will be shown if the login fails. Either the email or password is incorrect.
      .alert("Login Failed", isPresented: $showingLoginError) {
          Button("OK", role: .cancel) { }
      } message: {
          Text("Invalid email or password")
      }
      // Add success alert
      .alert("Success", isPresented: $showingLoginSuccess) {
          Button("Continue", role: .cancel) { }
      } message: {
          Text("You have successfully logged in!")
      }
  }
}


#Preview {
   ContentView()
}
