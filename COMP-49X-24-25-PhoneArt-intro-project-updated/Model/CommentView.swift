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
   @Environment(\.dismiss) private var dismiss // allows the view to be dismissed.
   @State private var newComment = ""
   @State private var posterName = "Loading..."
   @EnvironmentObject var userViewModel: UserViewModel
  
   // main view layout
   var body: some View {
       VStack(alignment: .leading, spacing: 16) {
           backButton()
           postDisplayView()
           Spacer()
       }
       .padding()
       .navigationBarHidden(true)
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
       .onAppear {
           Task {
               if let name = await userViewModel.getUserName(userId: post.userId) {
                   posterName = name
               }
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
       HStack {
           TextField("Add Comment...", text: $newComment)
               .padding(.horizontal, 12)
               .padding(.vertical, 7)
               .overlay(
                   RoundedRectangle(cornerRadius: 15)
                       .stroke(Color.gray.opacity(0.3), lineWidth: 4)
               )
           Button("Comment") {
               // comment backend to be implemented here.
               newComment = ""
           }
           .padding(.horizontal, 20)
           .padding(.vertical, 8)
           .background(Color(red: 0.0, green: 0.0, blue: 0.5))
           .foregroundColor(.white)
           .cornerRadius(15)
       }
       .padding(.top, 8)
   }
}
