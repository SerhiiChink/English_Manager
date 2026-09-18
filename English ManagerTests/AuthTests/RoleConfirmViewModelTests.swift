//
//  RoleConfirmViewModelTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 15.08.2026.
//

import XCTest
@testable import English_Manager

final class RoleConfirmViewModelTests: XCTestCase {
    // MARK: - Properties
    private var sut: RoleConfirmViewModel!
    private var mockFirestoreService: MockFirestoreService!
    private var mockAuthService: MockAuthService!
    
    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        mockFirestoreService = MockFirestoreService()
        mockAuthService = MockAuthService()
        let initialUser = User(
            id: "mock_user_id",
            name: "Test",
            surname: "User",
            email: "test@example.com",
            role: nil
        )
        mockFirestoreService.users[initialUser.id] = initialUser
    }

    override func tearDown() {
        sut = nil
        mockFirestoreService = nil
        mockAuthService = nil
        super.tearDown()
    }
    
    // MARK: - Confirm Tests
    func testConfirmSuccessUpdatesRoleAndTriggersSuccessCallback() {
        sut = RoleConfirmViewModel(
            role: .student,
            firestoreService: mockFirestoreService,
            authService: mockAuthService
        )
        let expectation = expectation(description: "Confirm Role Success")
        var loadingStates: [Bool] = []
        var confirmedRole: UserRole?
        sut.onLoading = { isLoading in
            loadingStates.append(isLoading)
        }
        sut.onSuccess = { role in
            confirmedRole = role
            expectation.fulfill()
        }
        sut.confirm()
        waitForExpectations(timeout: 1.0)
        let updatedUserInFirestore = mockFirestoreService.users["mock_user_id"]
        XCTAssertEqual(updatedUserInFirestore?.role, .student)
        XCTAssertEqual(confirmedRole, .student)
        XCTAssertEqual(loadingStates, [true, false])
        XCTAssertEqual(UserDefaults.standard.string(forKey: UDKeys.userRole), UserRole.student.rawValue)
    }

    func testConfirmWhenUserIdNotFoundTriggersErrorCallback() {
        mockAuthService.currentUserId = nil
        sut = RoleConfirmViewModel(
            role: .teacher,
            firestoreService: mockFirestoreService,
            authService: mockAuthService
        )
        var errorMessage: String?
        sut.onError = { message in
            errorMessage = message
        }
        sut.confirm()
        XCTAssertEqual(errorMessage, "User not found")
    }

    func testConfirmErrorTriggersErrorCallback() {
        mockFirestoreService.shouldReturnError = true
        sut = RoleConfirmViewModel(
            role: .teacher,
            firestoreService: mockFirestoreService,
            authService: mockAuthService
        )
        let expectation = expectation(description: "Confirm Role Error")
        var errorMessage: String?
        sut.onError = { message in
            errorMessage = message
            expectation.fulfill()
        }
        sut.confirm()
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(errorMessage, "Mock Firestore Error")
    }
}
