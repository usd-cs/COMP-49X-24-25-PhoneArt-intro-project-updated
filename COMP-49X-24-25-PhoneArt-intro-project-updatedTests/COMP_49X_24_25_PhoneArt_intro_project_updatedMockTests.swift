import XCTest
@testable import COMP_49X_24_25_PhoneArt_intro_project_updated
import FirebaseFirestore

// Mock Firestore Database for testing
class MockFirestore {
    var users: [String: [String: Any]] = [:]
    var posts: [String: [String: Any]] = [:]
    
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

class COMP_49X_24_25_PhoneArt_intro_project_updatedMockTests: XCTestCase {
    var mockUserViewModel: MockUserViewModel!
    var mockPostViewModel: MockPostViewModel!
    
    override func setUp() {
        super.setUp()
        mockUserViewModel = MockUserViewModel()
        mockPostViewModel = MockPostViewModel()
    }
    
    override func tearDown() {
        mockUserViewModel = nil
        mockPostViewModel = nil
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
    
}
