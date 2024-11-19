//
//  PostView.swift
//  COMP-49X-24-25-PhoneArt-intro-project-updated
//
//  Created by Aditya Prakash on 11/17/24.
//


import SwiftUI


struct PostView: View {
  @State private var newComment = ""
  @Binding var isAuthenticated: Bool
   var body: some View {
      NavigationStack {
          VStack(alignment: .leading, spacing: 16) {
              // Title view for Discussions
              titleView()
              // Post creation view
              postCreationView()
              .padding(.horizontal)
              .padding(.vertical, 30)
              .background(
                  RoundedRectangle(cornerRadius: 10)
                  .stroke(Color.gray.opacity(0.3), lineWidth: 4)
              )
             
              Spacer()
          }
          .padding()
          .toolbar {
              ToolbarItem(placement: .navigationBarTrailing) {
                  Button("Sign Out") {
                      isAuthenticated = false
                  }
                  .foregroundColor(.red)
              }
          }
      }
  }
  // UI for the title of the page
  private func titleView() -> some View {
      HStack {
          Text("Discussions")
              .font(.title)
              .bold()
          Spacer()
      }
  }
  // UI for the Post Creation Field
  private func postCreationView() -> some View {
      HStack {
          // Text Field for creating a new post
          TextField("Share your thoughts here...", text: $newComment)
              .padding(.horizontal, 12)
              .padding(.vertical, 7)
              .overlay(
                  RoundedRectangle(cornerRadius: 15)
                  .stroke(Color.gray.opacity(0.3), lineWidth: 4)
              )
          postButton()
      }
  }
  // UI for the Post Button
  private func postButton() -> some View {
      Button("Post") {
         
      }
      // Formatting for the Post Button
      .padding(.horizontal, 20)
      .padding(.vertical, 8)
      .background(Color(red: 0.5, green: 0.0, blue: 0.5))
      .foregroundColor(.white)
      .bold()
      .cornerRadius(15)
      .overlay(
          RoundedRectangle(cornerRadius: 15)
          .stroke(Color(red: 0.4, green: 0.0, blue: 0.4), lineWidth: 4)
      )
  }
}
