//
//  PostViewModel.swift
//  COMP-49X-24-25-PhoneArt-intro-project-updated
//
//  Created by Emmett de Bruin on 11/18/24.
//

import Foundation
import Firebase
import FirebaseFirestore

// Basic post model - just stores the essential info we need
struct Post: Codable, Identifiable {
   let id: String
   let userId: String
   let content: String
   let createdAt: Date
}

// Handles all the post-related Firebase operations
class PostViewModel: ObservableObject {
   @Published var posts: [Post] = [] // Keeps track of posts in memory
   private let db = Firestore.firestore() 
   private let commentViewModel: CommentViewModel // Need this to clean up comments when deleting posts

   init(commentViewModel: CommentViewModel) {
       self.commentViewModel = commentViewModel
   }
  
   // Creates a new post and adds it to both Firestore and local state
   func createPost(userId: String, content: String) async throws {
       do {
           let postRef = db.collection("posts").document()
           let post = Post(
               id: postRef.documentID,
               userId: userId,
               content: content,
               createdAt: Date()
           )
          
           try await postRef.setData([
               "id": post.id,
               "userId": post.userId,
               "content": post.content,
               "createdAt": Timestamp(date: post.createdAt)
           ])
          
           await MainActor.run {
               posts.append(post)
               posts.sort { $0.createdAt > $1.createdAt } // Keep newest posts at top
           }
       } catch {
           throw error
       }
   }
  
   // Gets all posts from Firestore, sorted newest first
   func fetchPosts() async throws {
       do {
           let querySnapshot = try await db.collection("posts")
               .order(by: "createdAt", descending: true)
               .getDocuments()
          
           let fetchedPosts = querySnapshot.documents.compactMap { document -> Post? in
               let data = document.data()
               // Skip any malformed posts in the DB
               guard let userId = data["userId"] as? String,
                     let content = data["content"] as? String,
                     let timestamp = data["createdAt"] as? Timestamp else {
                   return nil
               }
              
               return Post(
                   id: document.documentID,
                   userId: userId,
                   content: content,
                   createdAt: timestamp.dateValue()
               )
           }
          
           await MainActor.run {
               self.posts = fetchedPosts
           }
       } catch {
           throw error
       }
   }
    
   // Deletes a post and all its comments
   func deletePost(postId: String) async throws {
       do {
           // First find and delete all comments on this post
           let querySnapshot = try await db.collection("comments")
               .whereField("postId", isEqualTo: postId)
               .getDocuments()
             
           for document in querySnapshot.documents {
               try await commentViewModel.deleteComment(commentId: document.documentID, postId: postId)
           }
             
           try await db.collection("posts").document(postId).delete()
             
           await MainActor.run {
               posts.removeAll { $0.id == postId }
           }
       } catch {
           throw error
       }
   }
}