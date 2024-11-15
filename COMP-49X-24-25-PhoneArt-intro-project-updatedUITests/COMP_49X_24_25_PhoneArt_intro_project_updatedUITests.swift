//
//  COMP_49X_24_25_PhoneArt_intro_project_updatedUITests.swift
//  COMP-49X-24-25-PhoneArt-intro-project-updatedUITests
//
//  Created by Aditya Prakash on 11/14/24.
//

import XCTest

final class COMP_49X_24_25_PhoneArt_intro_project_updatedUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    @available(iOS 13.0, *)
    // Test the UI for the login page. 
    func testLoginFields() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Test email field exists and is interactive
        let emailField = app.textFields["Email"]
        XCTAssertTrue(emailField.exists)
        emailField.tap()
        emailField.typeText("test@example.com")
        
        // Test password field exists and is interactive
        let passwordField = app.secureTextFields["Password"]
        XCTAssertTrue(passwordField.exists)
        passwordField.tap()
        passwordField.typeText("password123")
        
        // Test sign in button exists
        let signInButton = app.buttons["Sign In"]
        XCTAssertTrue(signInButton.exists)
        signInButton.tap()
    }
    
    @MainActor
    @available(iOS 13.0, *)
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
