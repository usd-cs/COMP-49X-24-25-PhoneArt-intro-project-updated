import XCTest
@testable import COMP_49X_24_25_PhoneArt_intro_project_updated
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

final class LoginBackendTests: XCTestCase {
    var userViewModel: UserViewModel!
    
    override func setUp() {
        super.setUp()
        // Configure Firebase if not already configured
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        userViewModel = UserViewModel()
    }
    
    override func tearDown() {
        userViewModel = nil
        super.tearDown()
    }
    
    func testUserModelCreation() {
        // Test User struct creation
        let testUser = User(
            email: "test@example.com",
            name: "Test User",
            isAdmin: false,
            uid: "test123"
        )
        
        XCTAssertEqual(testUser.email, "test@example.com")
        XCTAssertEqual(testUser.name, "Test User")
        XCTAssertEqual(testUser.uid, "test123")
        XCTAssertFalse(testUser.isAdmin)
    }
    
    func testUserViewModelInitialization() {
        XCTAssertNotNil(userViewModel)
        XCTAssertNil(userViewModel.currentUser)
    }
    
    func testInvalidSignIn() {
        let expectation = expectation(description: "Invalid sign in")
        
        Task {
            do {
                try await userViewModel.signIn(email: "nonexistent@test.com", password: "wrongpassword")
                XCTFail("Sign in should fail with invalid credentials")
            } catch {
                // Expected to fail
                XCTAssertNil(userViewModel.currentUser)
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
} 