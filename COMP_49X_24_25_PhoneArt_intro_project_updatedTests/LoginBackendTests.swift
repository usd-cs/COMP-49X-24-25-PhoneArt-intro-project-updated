import XCTest
@testable import COMP_49X_24_25_PhoneArt_intro_project_updated
import FirebaseAuth

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
    
    func testCreateUserAndSignIn() {
        let expectation = expectation(description: "Create and sign in")
        let testEmail = "test\(Int.random(in: 1000...9999))@test.com"
        let testPassword = "password123"
        
        Task {
            do {
                // Create user
                try await userViewModel.createUser(email: testEmail, password: testPassword)
                // Sign in with created user
                try await userViewModel.signIn(email: testEmail, password: testPassword)
                expectation.fulfill()
            } catch {
                XCTFail("Authentication failed: \(error.localizedDescription)")
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10)
        XCTAssertFalse(userViewModel.showingLoginError)
    }
    
    func testSuccessfulSignIn() {
        let expectation = expectation(description: "Sign in")
        
        Task {
            do {
                try await userViewModel.signIn(email: "test@test.com", password: "password123")
                expectation.fulfill()
            } catch {
                XCTFail("Sign in failed: \(error.localizedDescription)")
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10)
        XCTAssertFalse(userViewModel.showingLoginError)
    }
    
    func testInvalidCredentialsSignIn() {
        let expectation = expectation(description: "Invalid sign in")
        
        Task {
            do {
                try await userViewModel.signIn(email: "invalid@test.com", password: "wrongpassword")
                XCTFail("Should not succeed with invalid credentials")
            } catch {
                // Expected to fail
                XCTAssertTrue(userViewModel.showingLoginError)
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10)
    }
} 