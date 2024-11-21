//
//  CommentViewModel.swift
//  COMP-49X-24-25-PhoneArt-intro-project-updated
//

import Foundation
import Firebase
import FirebaseFirestore

// Represents a single comment in the application
// Contains all the necessary information for displaying and managing comments
struct Comment: Codable, Identifiable {
    let id: String        
    let content: String   
    let userId: String   
    let postId: String   
    let createdAt: Date   
}

// Manages comment data and operations with Firestore
// Handles creating, fetching, and deleting comments
class CommentViewModel: ObservableObject {
    @Published var comments: [Comment] = []  
    private let db = Firestore.firestore()   
    
    // Creates a new comment and saves it to Firestore
    func createComment(userId: String, postId: String, content: String) async throws {
        do {
            let commentRef = db.collection("comments").document()
            let comment = Comment(
                id: commentRef.documentID,
                content: content,
                userId: userId,
                postId: postId,
                createdAt: Date()
            )
            
            // First, save to Firestore
            try await commentRef.setData([
                "id": comment.id,
                "content": comment.content,
                "userId": comment.userId,
                "postId": comment.postId,
                "createdAt": Timestamp(date: comment.createdAt)
            ])
            
            // After successful save, fetch all comments again
            try await fetchComments(forPostId: postId)
            
        } catch {
            throw error
        }
    }
    
    // Fetches all comments for a specific post
    func fetchComments(forPostId postId: String) async throws {
        do {
            let querySnapshot = try await db.collection("comments")
                .whereField("postId", isEqualTo: postId)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            let fetchedComments = querySnapshot.documents.compactMap { document -> Comment? in
                let data = document.data()
                guard let content = data["content"] as? String,
                      let userId = data["userId"] as? String,
                      let postId = data["postId"] as? String,
                      let timestamp = data["createdAt"] as? Timestamp else {
                    return nil
                }
                
                return Comment(
                    id: document.documentID,
                    content: content,
                    userId: userId,
                    postId: postId,
                    createdAt: timestamp.dateValue()
                )
            }
            
            await MainActor.run {
                self.comments = fetchedComments
            }
        } catch {
            throw error
        }
    }
    
    // Deletes a specific comment and refreshes the comments list
    func deleteComment(commentId: String, postId: String) async throws {
        do {
            // Delete from Firestore
            try await db.collection("comments").document(commentId).delete()
           
            // After successful deletion, refresh the comments list
            try await fetchComments(forPostId: postId)
        } catch {
            throw error
        }
    }

}
