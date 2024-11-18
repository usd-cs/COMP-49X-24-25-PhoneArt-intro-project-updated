import XCTest
@testable import COMP_49X_24_25_PhoneArt_intro_project_updated
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

final class LoginBackendTests: XCTestCase {
    var userViewModel: UserViewModel!
    
    override func setUp() {
        super.setUp()
        userViewModel = UserViewModel()
    }
    
    override func tearDown() {
        userViewModel = nil
        super.tearDown()
    }
    
    // MARK: - Model Tests
    
    func testUserModelProperties() {
        let testUser = User(
            email: "test@example.com",
            name: "Test User",
            isAdmin: false,
            uid: "test-uid-123"
        )
        
        XCTAssertEqual(testUser.email, "test@example.com", "Email should match")
        XCTAssertEqual(testUser.name, "Test User", "Name should match")
        XCTAssertFalse(testUser.isAdmin, "Should not be admin")
        XCTAssertEqual(testUser.uid, "test-uid-123", "UID should match")
    }
    
    func testUserModelCoding() {
        let testUser = User(
            email: "test@example.com",
            name: "Test User",
            isAdmin: true,
            uid: "test-uid-123"
        )
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(testUser)
            
            let decoder = JSONDecoder()
            let decodedUser = try decoder.decode(User.self, from: data)
            
            XCTAssertEqual(decodedUser.email, testUser.email)
            XCTAssertEqual(decodedUser.name, testUser.name)
            XCTAssertEqual(decodedUser.isAdmin, testUser.isAdmin)
            XCTAssertEqual(decodedUser.uid, testUser.uid)
        } catch {
            XCTFail("Coding failed: \(error)")
        }
    }
    
    // MARK: - ViewModel Tests
    
    func testViewModelInitialization() {
        XCTAssertNotNil(userViewModel, "ViewModel should be initialized")
        XCTAssertNil(userViewModel.currentUser, "Current user should be nil initially")
    }
    
    func testSignInValidation() {
        let expectation = XCTestExpectation(description: "Sign in validation")
        
        Task {
            do {
                try await userViewModel.signIn(email: "", password: "")
                XCTFail("Should fail with empty credentials")
            } catch {
                XCTAssertNil(userViewModel.currentUser)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testInvalidEmailFormat() {
        let expectation = XCTestExpectation(description: "Invalid email format")
        
        Task {
            do {
                try await userViewModel.signIn(email: "notanemail", password: "password123")
                XCTFail("Should fail with invalid email format")
            } catch {
                XCTAssertNil(userViewModel.currentUser)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testShortPassword() {
        let expectation = XCTestExpectation(description: "Short password")
        
        Task {
            do {
                try await userViewModel.createUser(
                    email: "test@example.com",
                    password: "123", // Too short
                    name: "Test",
                    isAdmin: false
                )
                XCTFail("Should fail with short password")
            } catch {
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
} 