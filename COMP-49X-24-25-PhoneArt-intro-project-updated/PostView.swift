//
//  PostView.swift
//  COMP-49X-24-25-PhoneArt-intro-project-updated
//
//  Created by Noah Huang on 11/18/24.
//


import SwiftUI


// Main view for displaying and creating posts/discussions
struct PostView: View {
   // State variables to manage UI
   @State private var newComment = ""
   @Binding var isAuthenticated: Bool
   @StateObject private var postViewModel = PostViewModel()
   @EnvironmentObject var userViewModel: UserViewModel
  
   var body: some View {
       NavigationStack {
           VStack(alignment: .leading, spacing: 16) {
               // Header showing "Discussions" title
               titleView()
              
               // Text field and button for creating new posts
               postCreationView()
                   .padding(.horizontal)
                   .padding(.vertical, 30)
                   .background(
                       RoundedRectangle(cornerRadius: 10)
                           .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                   )
              
               // Scrollable list of existing posts
               ScrollView {
                   LazyVStack {
                       ForEach(postViewModel.posts) { post in
                           PostItemView(post: post)
                               .environmentObject(userViewModel)
                       }
                   }
               }
              
               Spacer()
           }
           .padding()
           .toolbar {
               // Sign out button in navigation bar
               ToolbarItem(placement: .navigationBarTrailing) {
                   Button("Sign Out") {
                       isAuthenticated = false
                   }
                   .foregroundColor(.red)
               }
           }
           // Fetch posts when view appears
           .task {
               do {
                   try await postViewModel.fetchPosts()
               } catch {
                   print("Error fetching posts: \(error)")
               }
           }
       }
   }
  
   // Creates the header view with "Discussions" title
   private func titleView() -> some View {
       HStack {
           Text("Discussions")
               .font(.title)
               .bold()
           Spacer()
       }
   }
  
   // Creates the view containing the text field for new posts
   private func postCreationView() -> some View {
       HStack {
           // Text input field
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
  
   // Creates the post button with associated action
   private func postButton() -> some View {
       Button("Post") {
           // Verify user is logged in before posting
           guard let currentUser = userViewModel.currentUser else {
               print("Error: No user logged in")
               return
           }
          
           // Create new post in database
           Task {
               do {
                   try await postViewModel.createPost(
                       userId: currentUser.uid,
                       content: newComment
                   )
                   newComment = "" // Clear input field after posting
               } catch {
                   print("Error creating post: \(error)")
               }
           }
       }
       // Styling for post button
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
       .disabled(newComment.isEmpty) // Disable button when input is empty
   }
}


// View component for displaying a single post
struct PostItemView: View {
   @EnvironmentObject var userViewModel: UserViewModel
   @State private var posterName: String = "Loading..."
   @State private var isShowingComments = false
   let post: Post
  
   var body: some View {
       VStack(alignment: .leading, spacing: 4) {
           HStack {
               Text("Posted by \(posterName)")
                   .font(.caption)
                   .foregroundColor(.gray)
               Spacer()
               Text(post.createdAt.formatted())
                   .font(.caption)
                   .foregroundColor(.gray)
           }
           contentView()
           HStack {
               commentButton()
               Spacer()
           }
       }
       .padding(.horizontal)
       .padding(.top, 15)
       .padding(.bottom, 20)
       .background(
           RoundedRectangle(cornerRadius: 10)
               .stroke(Color.gray.opacity(0.3), lineWidth: 4)
       )
       .padding(.horizontal)
       .padding(.vertical, 8)
       // Fetch and display poster's name when view appears
       .onAppear {
           Task {
               if let name = await userViewModel.getUserName(userId: post.userId) {
                   posterName = name
               }
           }
       }
   }
  
   // Creates view for displaying post content
   private func contentView() -> some View {
       Text(post.content)
           .font(.body)
           .foregroundColor(.black)
           .padding()
           .frame(maxWidth: .infinity, alignment: .leading)
           .background(Color.gray.opacity(0.1))
           .cornerRadius(10)
   }
  
   // Creates the comments button
   private func commentButton() -> some View {
       NavigationLink(destination: CommentView(post: post)) {
           Text("Comments")
               .padding(.horizontal, 20)
               .padding(.vertical, 8)
               .background(Color(red: 0.0, green: 0.0, blue: 0.5))
               .foregroundColor(.white)
               .bold()
               .cornerRadius(15)
               .overlay(
                   RoundedRectangle(cornerRadius: 15)
                       .stroke(Color(red: 0.0, green: 0.0, blue: 0.4), lineWidth: 4)
               )
               .padding(.top, 8)
       }
   }
  
}
