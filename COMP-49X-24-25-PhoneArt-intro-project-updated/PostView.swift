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
   @Binding var isGuest: Bool
   @StateObject private var postViewModel = PostViewModel(commentViewModel: CommentViewModel())
   @StateObject private var commentViewModel = CommentViewModel()
   @EnvironmentObject var userViewModel: UserViewModel
  
   var body: some View {
       NavigationStack {
           // This stack includes the title, the post creation view, and the post list.
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
                           PostItemView(post: post, isGuest: isGuest)
                               .environmentObject(userViewModel)
                               .environmentObject(commentViewModel)
                               .environmentObject(postViewModel)
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
                       isGuest = true
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
           TextField(isGuest ? "Please login to add posts . . . " : "Share your thoughts here...", text: $newComment)
               .padding(.horizontal, 12)
               .padding(.vertical, 7)
               .overlay(
                   RoundedRectangle(cornerRadius: 15)
                       .stroke(Color.gray.opacity(0.3), lineWidth: 4)
               )
               .disabled(isGuest)
               .foregroundColor(isGuest ? Color(red: 0.502, green: 0.502, blue: 0.502) : Color.black)
           
           Button("Post") {
               guard !isGuest, let currentUser = userViewModel.currentUser else { return }
               
               Task {
                   do {
                       try await postViewModel.createPost(
                           userId: currentUser.uid,
                           content: newComment
                       )
                       newComment = ""
                   } catch {
                       print("Error creating post: \(error)")
                   }
               }
           }
           .padding(.horizontal, 20)
           .padding(.vertical, 8)
           .background(newComment.isEmpty || isGuest ? Color(red: 0.827, green: 0.827, blue: 0.827) : Color(red: 0.5, green: 0.0, blue: 0.5))
           .foregroundColor(newComment.isEmpty || isGuest ? Color(red: 0.502, green: 0.502, blue: 0.502) : Color.white)
           .bold()
           .cornerRadius(15)
           .overlay(
               RoundedRectangle(cornerRadius: 15)
                   .stroke(newComment.isEmpty || isGuest ? Color(red: 0.502, green: 0.502, blue: 0.502) : Color(red: 0.4, green: 0.0, blue: 0.4), lineWidth: 4)
           )
           .disabled(newComment.isEmpty || isGuest)
       }
   }
}

// View component for displaying a single post
struct PostItemView: View {
   @EnvironmentObject var userViewModel: UserViewModel
   @EnvironmentObject var commentViewModel: CommentViewModel
   @EnvironmentObject var postViewModel: PostViewModel
   @State private var posterName: String = "Loading..."
   @State private var isShowingComments = false
   @State private var showingDeleteAlert = false
   let post: Post
   let isGuest: Bool
  
   var body: some View {
       // This stack includes the poster's name, the post's creation date, and the post's content.
       VStack(alignment: .leading, spacing: 4) {
           // This stack includes the poster's name and the post's creation date.
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
       HStack {
           commentNavigationLink()
           Spacer()
           deleteButton()
       }
   }
   
   // Creates the delete button if user has permission
   private func deleteButton() -> some View {
       Group {
           // Check both isGuest states to ensure consistency
           if !isGuest && !userViewModel.isGuest, 
              let currentUser = userViewModel.currentUser,
              (currentUser.isAdmin || currentUser.uid == post.userId) {
               Button(action: {
                   showingDeleteAlert = true
               }) {
                   // Delete button formatting
                   Text("Delete")
                       .padding(.horizontal, 20)
                       .padding(.vertical, 8)
                       .background(Color(red: 0.7, green: 0, blue: 0))
                       .foregroundColor(.white)
                       .bold()
                       .cornerRadius(15)
                       .overlay(
                           RoundedRectangle(cornerRadius: 15)
                               .stroke(Color(red: 0.6, green: 0, blue: 0), lineWidth: 4)
                       )
                       .padding(.top, 8)
               }
               .alert("Delete Post", isPresented: $showingDeleteAlert) {
                   Button("Cancel", role: .cancel) { }
                   Button("Delete", role: .destructive) {
                       Task {
                           do {
                                try await postViewModel.deletePost(postId: post.id)
                           } catch {
                                print("Error deleting post: \(error)")
                           }
                       }
                    }
               } message: {
                   Text("Are you sure you want to delete this post?")
               }
           }
       }
   }
   
   // Creates the navigation link to comments
   private func commentNavigationLink() -> some View {
       NavigationLink(destination: CommentView(post: post, isGuest: isGuest)) {
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
