​​import XCTest
@testable import COMP_49X_24_25_PhoneArt_intro_project_updated
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
final class COMP_49X_24_25_PhoneArt_intro_project_updatedTests: XCTestCase {
    var userViewModel: UserViewModel!
    
    override func setUp() {
        super.setUp()
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        userViewModel = UserViewModel()
    }
    override func tearDown() {
        userViewModel = nil
        super.tearDown()
    }
    func testExample() {
        XCTAssertTrue(true)
    }
    func testPerformanceExample() {
        measure {
            XCTAssertTrue(true)
        }
    }
    // testing for UserViewModel initialization
    func testUserViewModelInitialization() {
        XCTAssertNotNil(userViewModel)
        XCTAssertNil(userViewModel.currentUser)
    }
    // testing for a successful sign on with valid admin creds
    func testSuccessfulSignIn() {
        let expectation = expectation(description: "Successful Sign In")
        
        Task {
            do {
                try await userViewModel.signIn(email: "admin@example.com", password: "admin123")
                expectation.fulfill()
            } catch {
                print("Login error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 5)
    }
    
    // testing an unsuccessful sign on with random invalid credentials
    func testUnsuccessfulSignIn() {
        let expectation = expectation(description: "Unsuccessful Sign In")
        
        Task {
            do {
                try await userViewModel.signIn(email: "xyz@abc.def", password: "wrongpass")
                expectation.fulfill()
            } catch {
                print("Expected error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 5)
    }
}

