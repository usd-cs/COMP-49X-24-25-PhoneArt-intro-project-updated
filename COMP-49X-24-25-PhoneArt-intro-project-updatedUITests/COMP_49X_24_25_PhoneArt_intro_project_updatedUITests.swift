//
//  COMP_49X_24_25_PhoneArt_intro_project_updatedUITests.swift
//  COMP-49X-24-25-PhoneArt-intro-project-updatedUITests
//
//  Created by Aditya Prakash on 11/17/24.
//

import XCTest

final class COMP_49X_24_25_PhoneArt_intro_project_updatedUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testLoginPageUIElements() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Test welcome header exists
        XCTAssertTrue(app.staticTexts["Welcome!"].exists)
        
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
        
        // Test sign in buttons exist and are tappable
        let signInButton = app.buttons["Sign In"]
        XCTAssertTrue(signInButton.exists)
        signInButton.tap()
        
        let guestSignInButton = app.buttons["Sign in as Guest"]
        XCTAssertTrue(guestSignInButton.exists)
        guestSignInButton.tap()
    }
    
    

    // @MainActor
    // func testLaunchPerformance() throws {
    //     if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
    //         measure(metrics: [XCTApplicationLaunchMetric()]) {
    //             XCUIApplication().launch()
    //         }
    //     }
    // }
}
