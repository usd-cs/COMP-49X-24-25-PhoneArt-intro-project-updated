import XCTest
@testable import COMP_49X_24_25_PhoneArt_intro_project_updated
import FirebaseFirestore

// Mock Firestore Database for testing
class MockFirestore {
    var users: [String: [String: Any]] = [:]
    var posts: [String: [String: Any]] = [:]
    var comments: [String: [String: Any]] = [:]
    
    func addUser(uid: String, data: [String: Any]) {
        users[uid] = data
    }
    
    func getUser(uid: String) -> [String: Any]? {
        return users[uid]
    }
    
    func queryUsers(field: String, value: Any) -> [[String: Any]] {
        return users.values.filter { $0[field] as? String == value as? String }
    }
    
    func addPost(id: String, data: [String: Any]) {
        posts[id] = data
    }
    
    func getPosts() -> [[String: Any]] {
        return Array(posts.values)
    }
    
    func addComment(id: String, data: [String: Any]) {
        comments[id] = data
    }
    
    func getComments(postId: String) -> [[String: Any]] {
        return comments.values.filter { $0["postId"] as? String == postId }
    }
}

class MockUserViewModel: ObservableObject {
    @Published var currentUser: User?
    private var mockDB = MockFirestore()
    
    func createUser(email: String, password: String, name: String, isAdmin: Bool) async throws {
        let mockUID = UUID().uuidString
        let userData: [String: Any] = [
            "email": email,
            "name": name,
            "isAdmin": isAdmin,
            "uid": mockUID
        ]
        mockDB.addUser(uid: mockUID, data: userData)
    }
    
    func signIn(email: String, password: String) async throws {
        let matchingUsers = mockDB.queryUsers(field: "email", value: email)
        
        guard let userData = matchingUsers.first else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        
        guard let userEmail = userData["email"] as? String,
              let userName = userData["name"] as? String,
              let userIsAdmin = userData["isAdmin"] as? Bool,
              let userUID = userData["uid"] as? String else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid user data"])
        }
        
        let user = User(email: userEmail, name: userName, isAdmin: userIsAdmin, uid: userUID)
        self.currentUser = user
    }
}

class MockPostViewModel: ObservableObject {
    @Published var posts: [Post] = []
    private var mockDB = MockFirestore()
    
    func createPost(userId: String, content: String) async throws {
        let postId = UUID().uuidString
        let createdAt = Date()
        
        let postData: [String: Any] = [
            "id": postId,
            "userId": userId,
            "content": content,
            "createdAt": createdAt
        ]
        
        mockDB.addPost(id: postId, data: postData)
        
        let post = Post(id: postId, userId: userId, content: content, createdAt: createdAt)
        posts.append(post)
        posts.sort { $0.createdAt > $1.createdAt }
    }
    
    func fetchPosts() async throws {
        let postData = mockDB.getPosts()
        posts = postData.compactMap { data in
            guard let id = data["id"] as? String,
                  let userId = data["userId"] as? String,
                  let content = data["content"] as? String,
                  let createdAt = data["createdAt"] as? Date else {
                return nil
            }
            return Post(id: id, userId: userId, content: content, createdAt: createdAt)
        }
        posts.sort { $0.createdAt > $1.createdAt }
    }
}

class MockCommentViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    private var mockDB = MockFirestore()
    
    func createComment(userId: String, postId: String, content: String) async throws {
        let commentId = UUID().uuidString
        let createdAt = Date()
        
        let commentData: [String: Any] = [
            "id": commentId,
            "userId": userId,
            "postId": postId,
            "content": content,
            "createdAt": createdAt
        ]
        
        mockDB.addComment(id: commentId, data: commentData)
        try await fetchComments(forPostId: postId)
    }
    
    func fetchComments(forPostId postId: String) async throws {
        let commentData = mockDB.getComments(postId: postId)
        comments = commentData.compactMap { data in
            guard let id = data["id"] as? String,
                  let userId = data["userId"] as? String,
                  let postId = data["postId"] as? String,
                  let content = data["content"] as? String,
                  let createdAt = data["createdAt"] as? Date else {
                return nil
            }
            return Comment(id: id, content: content, userId: userId, postId: postId, createdAt: createdAt)
        }
        comments.sort { $0.createdAt > $1.createdAt }
    }
}

class COMP_49X_24_25_PhoneArt_intro_project_updatedMockTests: XCTestCase {
    var mockUserViewModel: MockUserViewModel!
    var mockPostViewModel: MockPostViewModel!
    var mockCommentViewModel: MockCommentViewModel!
    
    override func setUp() {
        super.setUp()
        mockUserViewModel = MockUserViewModel()
        mockPostViewModel = MockPostViewModel()
        mockCommentViewModel = MockCommentViewModel()
    }
    
    override func tearDown() {
        mockUserViewModel = nil
        mockPostViewModel = nil
        mockCommentViewModel = nil
        super.tearDown()
    }
    
    // User Authentication Tests
    func testSuccessfulLogin() async throws {
        try await mockUserViewModel.createUser(
            email: "test@example.com",
            password: "password123",
            name: "Test User",
            isAdmin: false
        )
        
        try await mockUserViewModel.signIn(email: "test@example.com", password: "password123")
        
        XCTAssertEqual(mockUserViewModel.currentUser?.email, "test@example.com")
        XCTAssertEqual(mockUserViewModel.currentUser?.name, "Test User")
        XCTAssertEqual(mockUserViewModel.currentUser?.isAdmin, false)
    }
    
    func testInvalidLogin() async {
        do {
            try await mockUserViewModel.signIn(email: "nonexistent@example.com", password: "wrongpassword")
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    // Post Management Tests
    func testCreatePost() async throws {
        let userId = "testUser123"
        let content = "Test post content"
        
        try await mockPostViewModel.createPost(userId: userId, content: content)
        
        XCTAssertEqual(mockPostViewModel.posts.count, 1)
        XCTAssertEqual(mockPostViewModel.posts[0].userId, userId)
        XCTAssertEqual(mockPostViewModel.posts[0].content, content)
    }
    
    func testFetchPosts() async throws {
        // Create multiple posts
        try await mockPostViewModel.createPost(userId: "user1", content: "Post 1")
        try await mockPostViewModel.createPost(userId: "user2", content: "Post 2")
        
        // Clear posts array to simulate fresh fetch
        mockPostViewModel.posts = []
        
        // Fetch posts
        try await mockPostViewModel.fetchPosts()
        
        XCTAssertEqual(mockPostViewModel.posts.count, 2)
        XCTAssertTrue(mockPostViewModel.posts[0].createdAt > mockPostViewModel.posts[1].createdAt) // Check sorting
    }
    
    // Comment Management Tests
    func testCreateComment() async throws {
        let userId = "testUser123"
        let postId = "testPost123"
        let content = "Test comment content"
        
        try await mockCommentViewModel.createComment(userId: userId, postId: postId, content: content)
        
        XCTAssertEqual(mockCommentViewModel.comments.count, 1)
        XCTAssertEqual(mockCommentViewModel.comments[0].userId, userId)
        XCTAssertEqual(mockCommentViewModel.comments[0].postId, postId)
        XCTAssertEqual(mockCommentViewModel.comments[0].content, content)
    }
    
    func testFetchComments() async throws {
        let postId = "testPost123"
        
        // Create multiple comments
        try await mockCommentViewModel.createComment(userId: "user1", postId: postId, content: "Comment 1")
        try await mockCommentViewModel.createComment(userId: "user2", postId: postId, content: "Comment 2")
        
        // Clear comments array to simulate fresh fetch
        mockCommentViewModel.comments = []
        
        // Fetch comments
        try await mockCommentViewModel.fetchComments(forPostId: postId)
        
        XCTAssertEqual(mockCommentViewModel.comments.count, 2)
        XCTAssertTrue(mockCommentViewModel.comments[0].createdAt > mockCommentViewModel.comments[1].createdAt) // Check sorting
    }
}
