import XCTest
@testable import COMP_49X_24_25_PhoneArt_intro_project_updated
import FirebaseFirestore

// Mock Firestore Database for testing
class MockFirestore {
    var users: [String: [String: Any]] = [:]
    
    func addUser(uid: String, data: [String: Any]) {
        users[uid] = data
    }
    
    func getUser(uid: String) -> [String: Any]? {
        return users[uid]
    }
    
    func queryUsers(field: String, value: Any) -> [[String: Any]] {
        return users.values.filter { $0[field] as? String == value as? String }
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

class COMP_49X_24_25_PhoneArt_intro_project_updatedMockTests: XCTestCase {
    var mockUserViewModel: MockUserViewModel!
    
    override func setUp() {
        super.setUp()
        mockUserViewModel = MockUserViewModel()
    }
    
    override func tearDown() {
        mockUserViewModel = nil
        super.tearDown()
    }
    
    func testSuccessfulLogin() async throws {
        // Create a test user first
        try await mockUserViewModel.createUser(
            email: "test@example.com",
            password: "password123",
            name: "Test User",
            isAdmin: false
        )
        
        // Test successful login
        try await mockUserViewModel.signIn(email: "test@example.com", password: "password123")
        
        XCTAssertEqual(mockUserViewModel.currentUser?.email, "test@example.com")
        XCTAssertEqual(mockUserViewModel.currentUser?.name, "Test User")
        XCTAssertEqual(mockUserViewModel.currentUser?.isAdmin, false)
    }
    
    func testInvalidLogin() async {
        // Test signing in with non-existent user
        do {
            try await mockUserViewModel.signIn(email: "nonexistent@example.com", password: "wrongpassword")
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}
