import XCTest
@testable import COMP_49X_24_25_PhoneArt_intro_project_updated
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

// Mock Database
class MockDatabase {
    var users: [String: [String: Any]] = [:]
    var posts: [String: [String: Any]] = [:]
    var comments: [String: [String: Any]] = [:]
    
    func reset() {
        users.removeAll()
        posts.removeAll()
        comments.removeAll()
    }
}

// Mock User View Model
class MockUserViewModel: ObservableObject {
    @Published var currentUser: COMP_49X_24_25_PhoneArt_intro_project_updated.User?
    private var mockDB: MockDatabase
    
    init(mockDB: MockDatabase) {
        self.mockDB = mockDB
    }
    
    func createUser(email: String, password: String, name: String, isAdmin: Bool) async throws {
        let uid = UUID().uuidString
        let userData: [String: Any] = [
            "email": email,
            "name": name,
            "isAdmin": isAdmin,
            "uid": uid
        ]
        mockDB.users[uid] = userData
        currentUser = User(email: email, name: name, isAdmin: isAdmin, uid: uid)
    }
    
    func signIn(email: String, password: String) async throws {
        guard let userData = mockDB.users.first(where: { $0.value["email"] as? String == email }) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        
        currentUser = User(
            email: userData.value["email"] as! String,
            name: userData.value["name"] as! String,
            isAdmin: userData.value["isAdmin"] as! Bool,
            uid: userData.key
        )
    }
    
    func getUserName(userId: String) async -> String? {
        return mockDB.users[userId]?["name"] as? String
    }
}

// Mock Post View Model
class MockPostViewModel: ObservableObject {
    @Published var posts: [Post] = []
    private var mockDB: MockDatabase
    
    init(mockDB: MockDatabase) {
        self.mockDB = mockDB
    }
    
    func createPost(userId: String, content: String) async throws {
        let postId = UUID().uuidString
        let postData: [String: Any] = [
            "userId": userId,
            "content": content,
            "id": postId
        ]
        mockDB.posts[postId] = postData
    }
    
    func fetchPosts() async throws {
        posts = mockDB.posts.map { 
            Post(
                id: $0.key, 
                userId: $0.value["userId"] as! String, 
                content: $0.value["content"] as! String,
                createdAt: Date()
            )
        }
    }
    
    func deletePost(postId: String) async throws {
        mockDB.posts.removeValue(forKey: postId)
        posts.removeAll(where: { $0.id == postId })
    }
}

// Mock Comment View Model
class MockCommentViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    private var mockDB: MockDatabase
    
    init(mockDB: MockDatabase) {
        self.mockDB = mockDB
    }
    
    func createComment(userId: String, postId: String, content: String) async throws {
        let commentId = UUID().uuidString
        let commentData: [String: Any] = [
            "userId": userId,
            "postId": postId,
            "content": content,
            "id": commentId
        ]
        mockDB.comments[commentId] = commentData
    }
    
    func fetchComments(forPostId postId: String) async throws {
        comments = mockDB.comments
            .filter { $0.value["postId"] as! String == postId }
            .map { 
                Comment(
                    id: $0.key,
                    content: $0.value["content"] as! String,
                    userId: $0.value["userId"] as! String,
                    postId: $0.value["postId"] as! String,
                    createdAt: Date()
                )
            }
    }
    
    func deleteComment(commentId: String, postId: String) async throws {
        mockDB.comments.removeValue(forKey: commentId)
        comments.removeAll(where: { $0.id == commentId })
    }
}

class COMP_49X_24_25_PhoneArt_intro_project_updatedTests: XCTestCase {
    var mockDB: MockDatabase!
    var userViewModel: MockUserViewModel!
    var postViewModel: MockPostViewModel!
    var commentViewModel: MockCommentViewModel!
    
    override func setUp() {
        super.setUp()
        mockDB = MockDatabase()
        userViewModel = MockUserViewModel(mockDB: mockDB)
        postViewModel = MockPostViewModel(mockDB: mockDB)
        commentViewModel = MockCommentViewModel(mockDB: mockDB)
    }
    
    override func tearDown() {
        mockDB.reset()
        userViewModel = nil
        postViewModel = nil
        commentViewModel = nil
        super.tearDown()
    }
    
    func testUserViewModelInitialization() {
        XCTAssertNotNil(userViewModel)
        XCTAssertNil(userViewModel.currentUser)
    }
    
    func testSuccessfulSignIn() async throws {
        // First create a test user
        try await userViewModel.createUser(email: "admin@example.com", password: "admin123", name: "Admin", isAdmin: true)
        
        // Then try to sign in
        try await userViewModel.signIn(email: "admin@example.com", password: "admin123")
        
        XCTAssertNotNil(userViewModel.currentUser)
        XCTAssertEqual(userViewModel.currentUser?.email, "admin@example.com")
    }
    
    func testUnsuccessfulSignIn() async throws {
        do {
            try await userViewModel.signIn(email: "xyz@abc.def", password: "wrongpass")
            XCTFail("Should have thrown an error")
        } catch {
            // Expected error
            XCTAssertNotNil(error)
        }
    }
    
    func testCreateAndFetchPost() async throws {
        // Create test user
        try await userViewModel.createUser(email: "test@example.com", password: "test123", name: "Test User", isAdmin: false)
        let userId = userViewModel.currentUser!.uid
        
        // Create post
        try await postViewModel.createPost(userId: userId, content: "Test post content")
        
        // Fetch posts
        try await postViewModel.fetchPosts()
        
        XCTAssertFalse(postViewModel.posts.isEmpty)
        XCTAssertEqual(postViewModel.posts.first?.userId, userId)
        XCTAssertEqual(postViewModel.posts.first?.content, "Test post content")
    }
    
    func testCreateAndFetchComments() async throws {
        // Create test user
        try await userViewModel.createUser(email: "test@example.com", password: "test123", name: "Test User", isAdmin: false)
        let userId = userViewModel.currentUser!.uid
        
        // Create test post
        try await postViewModel.createPost(userId: userId, content: "Test post content")
        try await postViewModel.fetchPosts()
        let postId = postViewModel.posts.first!.id
        
        // Create comment
        try await commentViewModel.createComment(userId: userId, postId: postId, content: "Test comment content")
        
        // Fetch comments
        try await commentViewModel.fetchComments(forPostId: postId)
        
        XCTAssertFalse(commentViewModel.comments.isEmpty)
        XCTAssertEqual(commentViewModel.comments.first?.userId, userId)
        XCTAssertEqual(commentViewModel.comments.first?.content, "Test comment content")
        XCTAssertEqual(commentViewModel.comments.first?.postId, postId)
    }
    
    func testCreateUser() async throws {
        let testEmail = "test@example.com"
        let testPassword = "test123"
        let testName = "Test User"
        
        try await userViewModel.createUser(
            email: testEmail,
            password: testPassword,
            name: testName,
            isAdmin: false
        )
        
        try await userViewModel.signIn(email: testEmail, password: testPassword)
        
        XCTAssertNotNil(userViewModel.currentUser)
        XCTAssertEqual(userViewModel.currentUser?.email, testEmail)
        XCTAssertEqual(userViewModel.currentUser?.name, testName)
        XCTAssertFalse(userViewModel.currentUser?.isAdmin ?? true)
    }
    
    func testGetUserName() async throws {
        // Create test user
        try await userViewModel.createUser(email: "test@example.com", password: "test123", name: "Test User", isAdmin: false)
        let userId = userViewModel.currentUser!.uid
        
        let userName = await userViewModel.getUserName(userId: userId)
        XCTAssertEqual(userName, "Test User")
    }
    
    func testDeletePost() async throws {
        // Set up test admin user
        try await userViewModel.createUser(email: "test@example.com", password: "test123", name: "Test User", isAdmin: true)
        let userId = userViewModel.currentUser!.uid
        
        // Make a new post and fetch it
        try await postViewModel.createPost(userId: userId, content: "Test post to delete")
        try await postViewModel.fetchPosts()
        
        // Should have 1 post now
        XCTAssertEqual(postViewModel.posts.count, 1)
        let postId = postViewModel.posts.first!.id
        
        // Try deleting the post
        try await postViewModel.deletePost(postId: postId)
        
        // Post should be gone from both posts list and DB
        XCTAssertTrue(postViewModel.posts.isEmpty)
        XCTAssertNil(mockDB.posts[postId])
    }
    
    func testDeleteComment() async throws {
        // Need an admin user first
        try await userViewModel.createUser(email: "test@example.com", password: "test123", name: "Test User", isAdmin: true)
        let userId = userViewModel.currentUser!.uid
        
        // Need a post to comment on
        try await postViewModel.createPost(userId: userId, content: "Test post")
        try await postViewModel.fetchPosts()
        let postId = postViewModel.posts.first!.id
        
        // Add a test comment
        try await commentViewModel.createComment(userId: userId, postId: postId, content: "Test comment to delete")
        try await commentViewModel.fetchComments(forPostId: postId)
        
        // Should have 1 comment
        XCTAssertEqual(commentViewModel.comments.count, 1)
        let commentId = commentViewModel.comments.first!.id
        
        // Remove the comment
        try await commentViewModel.deleteComment(commentId: commentId, postId: postId)
        
        // Comment should be gone from both comments list and DB
        XCTAssertTrue(commentViewModel.comments.isEmpty)
        XCTAssertNil(mockDB.comments[commentId])
    }
}
