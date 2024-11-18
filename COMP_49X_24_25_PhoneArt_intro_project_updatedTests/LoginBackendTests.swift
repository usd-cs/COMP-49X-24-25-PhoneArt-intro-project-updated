func testCreateUserAndSignIn() async throws {
    // Create expectations
    let expectation = XCTestExpectation(description: "User creation and sign in")
    
    // Test email and password
    let testEmail = "test\(Int.random(in: 1000...9999))@test.com"
    let testPassword = "password123"
    
    // Attempt to create user and sign in
    try await userViewModel.createUser(email: testEmail, password: testPassword)
    try await userViewModel.signIn(email: testEmail, password: testPassword)
    
    // Verify the login state through UI alerts
    XCTAssertTrue(userViewModel.showingLoginSuccess)
    XCTAssertFalse(userViewModel.showingLoginError)
    
    // Wait for expectation
    await fulfillment(of: [expectation], timeout: 5.0)
}

func testSuccessfulSignIn() async throws {
    // Create expectation
    let expectation = XCTestExpectation(description: "Successful sign in")
    
    // Use known test credentials
    let testEmail = "test@test.com"
    let testPassword = "password123"
    
    // Attempt to sign in
    try await userViewModel.signIn(email: testEmail, password: testPassword)
    
    // Verify the login state through UI alerts
    XCTAssertTrue(userViewModel.showingLoginSuccess)
    XCTAssertFalse(userViewModel.showingLoginError)
    
    // Wait for expectation
    await fulfillment(of: [expectation], timeout: 5.0)
} 