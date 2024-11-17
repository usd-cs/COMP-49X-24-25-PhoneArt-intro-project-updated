//
//  COMP_49X_24_25_PhoneArt_intro_project_updatedUITestsLaunchTests.swift
//  COMP-49X-24-25-PhoneArt-intro-project-updatedUITests
//
//  Created by Aditya Prakash on 11/17/24.
//

import XCTest

final class COMP_49X_24_25_PhoneArt_intro_project_updatedUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
