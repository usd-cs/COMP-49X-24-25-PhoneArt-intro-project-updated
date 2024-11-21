//
//  CommentViewModel.swift
//  COMP-49X-24-25-PhoneArt-intro-project-updated
//

import Foundation
import Firebase
import FirebaseFirestore

// represents a single comment in the application
struct Comment: Codable, Identifiable {
    let id: String
    let content: String
    let userId: String
    let postId: String
    let createdAt: Date
}

// manages comment data and operations with Firestore
class CommentViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    private let db = Firestore.firestore()
    
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
            print("Error creating comment: \(error.localizedDescription)")
            throw error
        }
    }
    
    func fetchComments(forPostId postId: String) async throws {
        do {
            print("Fetching comments for post: \(postId)") // Debug print
            let querySnapshot = try await db.collection("comments")
                .whereField("postId", isEqualTo: postId)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            print("Found \(querySnapshot.documents.count) comments") // Debug print
            
            let fetchedComments = querySnapshot.documents.compactMap { document -> Comment? in
                let data = document.data()
                guard let content = data["content"] as? String,
                      let userId = data["userId"] as? String,
                      let postId = data["postId"] as? String,
                      let timestamp = data["createdAt"] as? Timestamp else {
                    print("Failed to parse comment document: \(document.documentID)") // Debug print
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
                print("Updating comments array with \(fetchedComments.count) comments") // Debug print
                self.comments = fetchedComments
            }
        } catch {
            print("Error fetching comments: \(error.localizedDescription)")
            throw error
        }
    }
    
    
    func deleteComment(commentId: String, postId: String) async throws {
        do {
            // Delete from Firestore
            try await db.collection("comments").document(commentId).delete()
           
            // After successful deletion, refresh the comments list
            try await fetchComments(forPostId: postId)
        } catch {
            print("Error deleting comment: \(error.localizedDescription)")
            throw error
        }
    }

}
