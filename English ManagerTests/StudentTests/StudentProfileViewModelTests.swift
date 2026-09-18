//
//  StudentProfileViewModelTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 15.08.2026.
//

import XCTest
@testable import English_Manager

@MainActor
final class StudentProfileViewModelTests: XCTestCase {
    // MARK: - Properties
    private var sut: StudentProfileViewModel!
    private var mockAuthService: MockAuthService!
    private var mockFirestoreService: MockFirestoreService!
    private var mockUserCache: MockUserCache!
    
    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
        mockFirestoreService = MockFirestoreService()
        mockUserCache = MockUserCache()
        sut = StudentProfileViewModel(
            firestoreService: mockFirestoreService,
            authService: mockAuthService,
            cache: mockUserCache
        )
    }

    override func tearDown() {
        sut = nil
        mockAuthService = nil
        mockFirestoreService = nil
        mockUserCache = nil
        super.tearDown()
    }
    
    // MARK: - Fetch Tests
    func testFetchProfileWhenUserNotLoggedInTriggersError() {
        mockAuthService.currentUserId = nil
        var errorMessage: String?
        sut.onError = { error in
            errorMessage = error
        }
        sut.fetchProfile()
        XCTAssertEqual(errorMessage, "User not found")
    }

    func testFetchProfileSuccessfullyLoadsData() async {
        let studentId = "student_123"
        let teacherId = "teacher_999"
        mockAuthService.currentUserId = studentId
        let student = User(id: studentId,
                           name: "Anna",
                           surname: "Smith",
                           email: "a@e.com",
                           teacherId: teacherId)
        let teacher = User(id: teacherId,
                           name: "John",
                           surname: "Doe",
                           email: "t@e.com")
        mockFirestoreService.users[studentId] = student
        mockFirestoreService.users[teacherId] = teacher
        let exp = expectation(description: "Fetch completed")
        sut.onUpdate = { exp.fulfill() }
        sut.fetchProfile()
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertEqual(sut.user?.id, studentId)
        XCTAssertEqual(sut.teacher?.id, teacherId)
    }

    // MARK: - Auth Actions Tests
    func testSignOutClearsUserData() {
        mockAuthService.currentUserId = "user_123"
        sut.signOut()
        XCTAssertTrue(mockAuthService.signOutCalled)
    }

    func testChangePasswordSuccessTriggersUpdate() async {
        let studentId = "student_123"
        mockAuthService.currentUserId = studentId
        mockFirestoreService.users[studentId] = User(
            id: studentId,
            name: "Anna",
            surname: "Smith",
            email: "a@e.com"
        )
        let exp = expectation(description: "Password changed")
        sut.onUpdate = { exp.fulfill() }
        sut.changePassword("newPassword123")
        await fulfillment(of: [exp], timeout: 2.0)
    }

    func testDeleteAccountSuccessTriggersOnAccountDeleted() async {
        let exp = expectation(description: "Account deleted")
        sut.onAccountDeleted = { exp.fulfill() }
        sut.deleteAccount(email: "test@example.com", password: "password")
        await fulfillment(of: [exp], timeout: 2.0)
    }
}
