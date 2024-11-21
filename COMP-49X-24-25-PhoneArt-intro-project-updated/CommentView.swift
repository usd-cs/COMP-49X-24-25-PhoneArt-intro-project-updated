//
//  CommentView.swift
//  COMP-49X-24-25-PhoneArt-intro-project-updated
//
//  Created by Zachary Letcher on 11/19/24.
//
import SwiftUI




// view for displaying comments on a specific post
struct CommentView: View {
  let post: Post
  let isGuest: Bool
  @Environment(\.dismiss) private var dismiss // allows the view to be dismissed.
  @State private var newComment = ""
  @State private var posterName = "Loading..."
  @EnvironmentObject var userViewModel: UserViewModel
  @StateObject private var commentViewModel = CommentViewModel()
  @State private var refreshID = UUID()
   // main view layout
  var body: some View {
      VStack(alignment: .leading, spacing: 16) {
          backButton()
          postDisplayView()
          commentsList()
          Spacer()
      }
      .padding()
      .navigationBarHidden(true)
      .id(refreshID)
      .onAppear {
          Task {
              do {
                  print("CommentView appeared, fetching comments")
                  try await commentViewModel.fetchComments(forPostId: post.id)
              } catch {
                  print("Error fetching comments: \(error)")
              }
          }
      }
  }
   // creates a back button to return to previous view
  private func backButton() -> some View {
      Button(action: {
          dismiss()
      }) {
          HStack {
              Image(systemName: "chevron.left")
              Text("Back")
          }
      }
      .padding(.bottom)
  }
   // displays the post content and comment input
  private func postDisplayView() -> some View {
      // this following the same structure as PostView.swift.
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
          commentInputView()
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
      .task {
          if let name = await userViewModel.getUserName(userId: post.userId) {
              posterName = name
          } else {
              posterName = "Unknown User"
          }
      }
  }
   // displays the content of the post
  private func contentView() -> some View {
      Text(post.content)
          .font(.body)
          .foregroundColor(.black)
          .padding()
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(Color.gray.opacity(0.1))
          .cornerRadius(10)
  }
   // provides input field and button for adding new comments
  private func commentInputView() -> some View {
       // Debug prints to verify state
       print("isGuest: \(isGuest)")
       print("currentUser: \(String(describing: userViewModel.currentUser))")
       
       let placeholderText = isGuest ? "Please login to add comments..." : "Add Comment..."
       
       return HStack {
           TextField(placeholderText, text: $newComment)
               .padding(.horizontal, 12)
               .padding(.vertical, 7)
               .overlay(
                   RoundedRectangle(cornerRadius: 15)
                       .stroke(Color.gray.opacity(0.3), lineWidth: 4)
               )
               .disabled(isGuest)
               .foregroundColor(isGuest ? Color(red: 0.502, green: 0.502, blue: 0.502) : Color.black)
               
           Button("Comment") {
               guard let currentUser = userViewModel.currentUser,
                     !newComment.isEmpty else { return }
               
               Task {
                   do {
                       try await commentViewModel.createComment(
                           userId: currentUser.uid,
                           postId: post.id,
                           content: newComment
                       )
                       newComment = ""
                       refreshID = UUID()
                   } catch {
                       print("Error creating comment: \(error)")
                   }
               }
           }
           .padding(.horizontal, 20)
           .padding(.vertical, 8)
           .background(newComment.isEmpty || isGuest ? Color(red: 0.827, green: 0.827, blue: 0.827) : Color(red: 0.0, green: 0.0, blue: 0.5))
           .foregroundColor(newComment.isEmpty || isGuest ? Color(red: 0.502, green: 0.502, blue: 0.502) : Color.white)
           .bold()
           .cornerRadius(15)
           .overlay(
               RoundedRectangle(cornerRadius: 15)
                   .stroke(newComment.isEmpty || isGuest ? Color(red: 0.502, green: 0.502, blue: 0.502) : Color(red: 0.0, green: 0.0, blue: 0.4), lineWidth: 4)
           )
           .disabled(newComment.isEmpty || isGuest)
       }
       .padding(.top, 8)
  }
   private func commentsList() -> some View {
      ScrollView {
          LazyVStack(alignment: .leading, spacing: 12) {
              ForEach(commentViewModel.comments) { comment in
                  CommentRowView(comment: comment, isGuest: isGuest)
                      .environmentObject(userViewModel)
              }
          }
      }
  }
}


struct CommentRowView: View {
   let comment: Comment
   let isGuest: Bool
   @EnvironmentObject var userViewModel: UserViewModel
   @StateObject private var commentViewModel = CommentViewModel()
   @State private var commenterName = "Loading..."
   @State private var showingDeleteAlert = false
   @State private var isDeleted = false
  
   var body: some View {
       if !isDeleted {  // Only show the comment if it's not deleted
           VStack(alignment: .leading, spacing: 4) {
               commentHeader()
               commentContent()
               deleteButtonIfAllowed()
           }
           .padding(.horizontal)
           .padding(.vertical, 8)
           .task {
               if let name = await userViewModel.getUserName(userId: comment.userId) {
                   commenterName = name
               } else {
                   commenterName = "Unknown User"
               }
           }
       }
   }
  
   private func commentHeader() -> some View {
       // This stack includes the commenter's name and the comment's creation date.
       HStack {
           Text(commenterName)
               .font(.caption)
               .foregroundColor(.gray)
           Spacer()
           Text(comment.createdAt.formatted())
               .font(.caption)
               .foregroundColor(.gray)
       }
   }
  
   private func commentContent() -> some View {
       Text(comment.content)
           .font(.body)
           .foregroundColor(.black)
           .padding()
           .frame(maxWidth: .infinity, alignment: .leading)
           .background(Color.gray.opacity(0.1))
           .cornerRadius(10)
   }
  
   private func deleteButtonIfAllowed() -> some View {
       Group {
           if !isDeleted && !isGuest && 
              (userViewModel.currentUser?.isAdmin == true ||
               userViewModel.currentUser?.uid == comment.userId) {
               HStack {
                   Spacer()
                   Button(action: {
                       showingDeleteAlert = true
                   }) {
                       HStack {
                           Text("Delete")
                               .foregroundColor(.red)
                       }
                   }
                   .alert("Delete Comment", isPresented: $showingDeleteAlert) {
                       Button("Cancel", role: .cancel) { }
                       Button("Delete", role: .destructive) {
                           Task {
                               do {
                                   try await commentViewModel.deleteComment(
                                       commentId: comment.id,
                                       postId: comment.postId
                                   )
                                   isDeleted = true
                                   NotificationCenter.default.post(
                                       name: Notification.Name("RefreshComments"),
                                       object: nil
                                   )
                               } catch {
                                   print("Error deleting comment: \(error)")
                               }
                           }
                       }
                   } message: {
                       Text("Are you sure you want to delete this comment?")
                   }
               }
           }
       }
   }
}




