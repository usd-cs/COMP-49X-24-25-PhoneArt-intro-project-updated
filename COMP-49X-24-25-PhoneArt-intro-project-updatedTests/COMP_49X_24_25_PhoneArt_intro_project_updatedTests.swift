//
//  COMP_49X_24_25_PhoneArt_intro_project_updatedTests.swift
//  COMP-49X-24-25-PhoneArt-intro-project-updatedTests
//
//  Created by Aditya Prakash on 11/17/24.
//

import XCTest
@testable import COMP_49X_24_25_PhoneArt_intro_project_updated

final class COMP_49X_24_25_PhoneArt_intro_project_updatedTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

class LoginBackendTests: XCTestCase {
    var userViewModel: UserViewModel!
    
    override func setUp() {
        super.setUp()
        userViewModel = UserViewModel()
    }
    
    override func tearDown() {
        userViewModel = nil
        super.tearDown()
    }
    
    func testSuccessfulSignIn() async throws {
        // valid credential test
        do {
            try await userViewModel.signIn(email: "test@example.com", password: "password123")
            XCTAssertNotNil(userViewModel.currentUser, "Current user should not be nil after successful sign in")
            XCTAssertEqual(userViewModel.currentUser?.email, "test@example.com")
        } catch {
            XCTFail("Sign in should succeed with valid credentials: \(error.localizedDescription)")
        }
    }
    
    func testInvalidCredentialsSignIn() async throws {
        
        do {
            try await userViewModel.signIn(email: "invalid@example.com", password: "wrongpassword")
            XCTFail("Sign in should fail with invalid credentials")
        } catch {
            XCTAssertNil(userViewModel.currentUser, "Current user should be nil after failed sign in")
        }
    }
    
    func testCreateUserAndSignIn() async throws {
        let testEmail = "newuser@example.com"
        let testPassword = "newpassword123"
        let testName = "Test User"
        
        //tesing user creation
        do {
            try await userViewModel.createUser(email: testEmail, 
                                             password: testPassword, 
                                             name: testName, 
                                             isAdmin: false)
            
            //tests the sign in for users
            try await userViewModel.signIn(email: testEmail, password: testPassword)
            
            XCTAssertNotNil(userViewModel.currentUser)
            XCTAssertEqual(userViewModel.currentUser?.email, testEmail)
            XCTAssertEqual(userViewModel.currentUser?.name, testName)
            XCTAssertFalse(userViewModel.currentUser?.isAdmin ?? true)
        } catch {
            XCTFail("User creation and sign in should succeed: \(error.localizedDescription)")
        }
    }
}
