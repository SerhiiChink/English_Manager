//
//  LoginViewModelTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 15.08.2026.
//

import XCTest
@testable import English_Manager

final class LoginViewModelTests: XCTestCase {
    // MARK: - Properties
    private var sut: LoginViewModel!
    private var mockAuthService: MockAuthService!
    private var mockValidationService: MockValidationService!
    private var mockFirestoreService: MockFirestoreService!

    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
        mockValidationService = MockValidationService()
        mockFirestoreService = MockFirestoreService()
        sut = LoginViewModel(
            authService: mockAuthService,
            validator: mockValidationService,
            firestoreService: mockFirestoreService
        )
    }

    override func tearDown() {
        sut = nil
        mockAuthService = nil
        mockValidationService = nil
        mockFirestoreService = nil
        super.tearDown()
    }

    // MARK: - Login Tests
    func testLoginSuccessTriggersSuccessCallback() {
        let expectation = expectation(description: "Login Success")
        var loadingStates: [Bool] = []
        sut.onLoading = { isLoading in
            loadingStates.append(isLoading)
        }
        sut.onSuccess = {
            expectation.fulfill()
        }
        sut.login(email: "test@example.com", password: "Password123")
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(mockAuthService.signInCalledWith?.email, "test@example.com")
        XCTAssertEqual(mockAuthService.signInCalledWith?.password, "Password123")
        XCTAssertEqual(loadingStates, [true, false])
    }

    func testLoginValidationErrorTriggersErrorCallback() {
        mockValidationService.validationResultToReturn = .failure("Invalid email")
        var errorMessage: String?
        sut.onError = { message in
            errorMessage = message
        }
        sut.login(email: "invalid_email", password: "123")
        XCTAssertEqual(errorMessage, "Invalid email")
        XCTAssertNil(mockAuthService.signInCalledWith)
    }

    func testLoginAuthErrorTriggersErrorCallback() {
        mockAuthService.shouldReturnError = true
        let expectation = expectation(description: "Login Error")
        var errorMessage: String?
        sut.onError = { message in
            errorMessage = message
            expectation.fulfill()
        }
        sut.login(email: "test@example.com", password: "Password123")
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(errorMessage, "Mock Auth Error")
    }

    // MARK: - Register Tests
    func testRegisterSuccessSavesUserAndTriggersSuccessCallback() {
        let expectation = expectation(description: "Register Success")
        sut.onSuccess = {
            expectation.fulfill()
        }
        sut.register(email: "new@example.com",
                     password: "Password123",
                     name: "John Doe")
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(mockAuthService.signUpCalledWith?.email, "new@example.com")
        XCTAssertEqual(mockAuthService.signUpCalledWith?.password, "Password123")
        XCTAssertTrue(mockFirestoreService.saveUserCalled)
        let savedUser = mockFirestoreService.users["mock_user_id"]
        XCTAssertEqual(savedUser?.name, "John")
        XCTAssertEqual(savedUser?.surname, "Doe")
        XCTAssertEqual(savedUser?.email, "new@example.com")
    }

    func testRegisterValidationErrorTriggersErrorCallback() {
        mockValidationService.validationResultToReturn = .failure("Password too short")
        var errorMessage: String?
        sut.onError = { message in
            errorMessage = message
        }
        sut.register(email: "test@example.com", password: "123", name: "John")
        XCTAssertEqual(errorMessage, "Password too short")
        XCTAssertNil(mockAuthService.signUpCalledWith)
        XCTAssertFalse(mockFirestoreService.saveUserCalled)
    }

    // MARK: - Reset Password Tests
    func testResetPasswordSuccessTriggersSuccessCallback() {
        let expectation = expectation(description: "Reset Password Success")
        sut.onSuccess = {
            expectation.fulfill()
        }
        sut.resetPassword(email: "reset@example.com")
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(mockAuthService.resetPasswordCalledWithEmail, "reset@example.com")
    }

    func testResetPasswordValidationErrorTriggersErrorCallback() {
        mockValidationService.validationResultToReturn = .failure("Email cannot be empty")
        var errorMessage: String?
        sut.onError = { message in
            errorMessage = message
        }
        sut.resetPassword(email: "")
        XCTAssertEqual(errorMessage, "Email cannot be empty")
        XCTAssertNil(mockAuthService.resetPasswordCalledWithEmail)
    }
}
