import Foundation
import Firebase
import FirebaseFirestore

// represents a single post in the application
struct Post: Codable, Identifiable {
    let id: String // unique identifier for the post
    let userId: String // id of user who created the post
    let content: String // text content of the post
    let createdAt: Date // timestamp when post was created
}

// manages post data and operations with Firestore
class PostViewModel: ObservableObject {
    @Published var posts: [Post] = [] // array of posts to display
    private let db = Firestore.firestore() // firestore database reference
    
    // creates a new post in firestore and updates local state
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
                // sort posts by creation date, newest first
                posts.sort { $0.createdAt > $1.createdAt }
            }
        } catch {
            print("Error creating post: \(error.localizedDescription)")
            throw error
        }
    }
    
    // fetches all posts from firestore and updates local state
    func fetchPosts() async throws {
        do {
            let querySnapshot = try await db.collection("posts")
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            let fetchedPosts = querySnapshot.documents.compactMap { document -> Post? in
                let data = document.data()
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
            print("Error fetching posts: \(error.localizedDescription)")
            throw error
        }
    }
    
    
}
