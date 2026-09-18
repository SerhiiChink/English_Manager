//
//  SplashViewModelTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 15.08.2026.
//

import XCTest
@testable import English_Manager

@MainActor
final class SplashViewModelTests: XCTestCase {
    // MARK: - Properties
    private var sut: SplashViewModel!
    private var mockAuthService: MockAuthService!
    private var mockFirestoreService: MockFirestoreService!
    
    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
        mockFirestoreService = MockFirestoreService()
        sut = SplashViewModel(
            authService: mockAuthService,
            firestoreService: mockFirestoreService
        )
    }
    
    override func tearDown() {
        sut = nil
        mockAuthService = nil
        mockFirestoreService = nil
        super.tearDown()
    }
    
    // MARK: - Resolve Tests
    func testResolveWhenUserNotLoggedInTriggersShowLogin() {
        mockAuthService.isLoggedIn = false
        mockAuthService.currentUserId = nil
        var showLoginCalled = false
        sut.onShowLogin = {
            showLoginCalled = true
        }
        sut.resolve()
        XCTAssertTrue(showLoginCalled)
    }

    func testResolveWhenUserHasRoleTriggersShowMain() {
        mockAuthService.isLoggedIn = true
        mockAuthService.currentUserId = "user_123"
        let userWithRole = User(
            id: "user_123",
            name: "John",
            surname: "Doe",
            email: "john@example.com",
            role: .student
        )
        mockFirestoreService.users["user_123"] = userWithRole
        let expectation = expectation(description: "Show Main Triggered")
        var navigatedRole: UserRole?
        sut.onShowMain = { role in
            navigatedRole = role
            expectation.fulfill()
        }
        sut.resolve()
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(navigatedRole, .student)
    }

    func testResolveWhenUserHasNoRoleTriggersShowRole() {
        mockAuthService.isLoggedIn = true
        mockAuthService.currentUserId = "user_123"
        let userWithoutRole = User(
            id: "user_123",
            name: "John",
            surname: "Doe",
            email: "john@example.com",
            role: nil
        )
        mockFirestoreService.users["user_123"] = userWithoutRole
        let expectation = expectation(description: "Show Role Triggered")
        var showRoleCalled = false
        sut.onShowRole = {
            showRoleCalled = true
            expectation.fulfill()
        }
        sut.resolve()
        waitForExpectations(timeout: 1.0)
        XCTAssertTrue(showRoleCalled)
    }

    func testResolveUpdatesTimezoneWhenChanged() {
        mockAuthService.isLoggedIn = true
        mockAuthService.currentUserId = "user_123"
        let user = User(
            id: "user_123",
            name: "John",
            surname: "Doe",
            email: "john@example.com",
            role: .teacher
        )
        mockFirestoreService.users["user_123"] = user
        let key = UDKeys.last_timezone(userId: "user_123")
        UserDefaults.standard.removeObject(forKey: key)
        let exp = expectation(description: "Timezone Updated")
        
        sut.onShowMain = { _ in
            exp.fulfill()
        }
        sut.resolve()
        waitForExpectations(timeout: 1.0)
        let updatedUser = mockFirestoreService.users["user_123"]
        XCTAssertEqual(updatedUser?.timezone, TimeZone.current.identifier)
        XCTAssertEqual(UserDefaults.standard.string(forKey: key), TimeZone.current.identifier)
    }
}
