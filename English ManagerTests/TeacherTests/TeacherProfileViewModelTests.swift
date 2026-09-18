//
//  TeacherProfileViewModelTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 16.08.2026.
//

import XCTest
import AuthenticationServices
@testable import English_Manager

@MainActor
final class TeacherProfileViewModelTests: XCTestCase {
    // MARK: - Properties
    private var sut: TeacherProfileViewModel!
    private var mockAuthService: MockAuthService!
    private var mockFirestoreService: MockFirestoreService!
    private var mockUserCache: MockUserCache!

    // MARK: - Lifecycle
    override func setUp() async throws {
        try await super.setUp()
        mockAuthService = MockAuthService()
        mockFirestoreService = MockFirestoreService()
        mockUserCache = MockUserCache()
        sut = TeacherProfileViewModel(
            firestoreService: mockFirestoreService,
            authService: mockAuthService,
            cache: mockUserCache
        )
    }

    override func tearDown() async throws {
        sut = nil
        mockAuthService = nil
        mockFirestoreService = nil
        mockUserCache = nil
        try await super.tearDown()
    }

    // MARK: - Helpers
    private func makeTeacher(id: String = "teacher_123") -> User {
        User(id: id, name: "John", surname: "Doe", email: "teacher@test.com", role: .teacher)
    }

    private func makeStudent(id: String, teacherId: String) -> User {
        User(id: id, name: "Student", surname: "Test", email: "\(id)@test.com", role: .student, teacherId: teacherId)
    }

    private func makeLesson(teacherId: String, studentId: String) -> Lesson {
        Lesson(
            studentId: studentId,
            teacherId: teacherId,
            studentName: "Student Test",
            date: Date(),
            topic: "Topic",
            bookTitle: "",
            pages: "",
            attended: true,
            vocabulary: [],
            sourceLinks: []
        )
    }
    
    private func makeTestViewController() -> UIViewController {
        let window = UIWindow()
        let vc = UIViewController()
        window.rootViewController = vc
        window.makeKeyAndVisible()
        return vc
    }

    // MARK: - Fetch Tests
    func testFetchProfile_whenNoUserId_triggersError() {
        mockAuthService.currentUserId = nil
        var errorMessage: String?
        sut.onError = { errorMessage = $0 }
        sut.fetchProfile()
        XCTAssertEqual(errorMessage, "User not found")
        XCTAssertNil(sut.user)
    }

    func testFetchProfile_success_loadsUserAndStats() async {
        let teacherId = "teacher_123"
        mockAuthService.currentUserId = teacherId
        mockFirestoreService.users[teacherId] = makeTeacher(id: teacherId)
        mockFirestoreService.users["s1"] = makeStudent(id: "s1", teacherId: teacherId)
        mockFirestoreService.lessons["l1"] = makeLesson(teacherId: teacherId, studentId: "s1")
        let exp = expectation(description: "onUpdate called")
        sut.onUpdate = { exp.fulfill() }
        sut.fetchProfile()
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertEqual(sut.user?.id, teacherId)
        XCTAssertEqual(sut.statItems.count, 2)
        XCTAssertEqual(sut.statItems.first(where: { $0.title == "students".localized })?.value, "1")
        XCTAssertEqual(sut.statItems.first(where: { $0.title == "lessons_capitalized".localized })?.value, "1")
    }

    func testFetchProfile_whenFirestoreError_triggersOnError() async {
        mockAuthService.currentUserId = "teacher_123"
        mockFirestoreService.shouldReturnError = true
        let exp = expectation(description: "onError called")
        sut.onError = { _ in exp.fulfill() }
        sut.fetchProfile()
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertNil(sut.user)
    }

    func testFetchProfile_preventsConcurrentRequests() async {
        let teacherId = "teacher_123"
        mockAuthService.currentUserId = teacherId
        mockFirestoreService.users[teacherId] = makeTeacher(id: teacherId)
        var updateCount = 0
        let exp = expectation(description: "onUpdate called once")
        sut.onUpdate = {
            updateCount += 1
            exp.fulfill()
        }
        sut.fetchProfile()
        sut.fetchProfile()
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertEqual(updateCount, 1)
    }

    // MARK: - Sign Out Tests
    func testSignOut_callsAuthService() {
        sut.signOut()
        XCTAssertTrue(mockAuthService.signOutCalled)
    }

    func testSignOut_whenError_triggersOnError() {
        mockAuthService.shouldReturnError = true
        var errorMessage: String?
        sut.onError = { errorMessage = $0 }
        sut.signOut()
        XCTAssertNotNil(errorMessage)
    }

    // MARK: - Change Password Tests
    func testChangePassword_success_triggersOnUpdate() async {
        let exp = expectation(description: "onUpdate called")
        sut.onUpdate = { exp.fulfill() }
        sut.changePassword("newSecretPassword123")
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertEqual(mockAuthService.changePasswordCalledWith, "newSecretPassword123")
    }

    func testChangePassword_whenError_triggersOnError() async {
        mockAuthService.shouldReturnError = true
        let exp = expectation(description: "onError called")
        sut.onError = { _ in exp.fulfill() }
        sut.changePassword("newSecretPassword123")
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertNil(mockAuthService.changePasswordCalledWith)
    }

    // MARK: - Delete Account Tests
    func testDeleteAccount_success_triggersOnAccountDeleted() async {
        let exp = expectation(description: "onAccountDeleted called")
        sut.onAccountDeleted = { exp.fulfill() }
        sut.deleteAccount(email: "teacher@test.com", password: "password123")
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertTrue(mockAuthService.deleteAccountCalled)
    }

    func testDeleteAccount_whenError_triggersOnError() async {
        mockAuthService.shouldReturnError = true
        let exp = expectation(description: "onError called")
        sut.onError = { _ in exp.fulfill() }
        sut.deleteAccount(email: "teacher@test.com", password: "password123")
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertFalse(mockAuthService.deleteAccountCalled)
    }

    func testDeleteAccountWithGoogle_success_triggersOnAccountDeleted() async {
        let exp = expectation(description: "onAccountDeleted called")
        sut.onAccountDeleted = { exp.fulfill() }
        sut.deleteAccountWithGoogle(presenting: makeTestViewController())
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertTrue(mockAuthService.deleteAccountWithGoogleCalled)
    }

    func testDeleteAccountWithApple_success_triggersOnAccountDeleted() async {
        let exp = expectation(description: "onAccountDeleted called")
        sut.onAccountDeleted = { exp.fulfill() }
        sut.deleteAccountWithApple(window: UIWindow())
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertTrue(mockAuthService.deleteAccountWithAppleCalled)
    }

    func testDeleteAccountWithApple_whenUserCanceled_doesNotTriggerOnError() async {
        mockAuthService.shouldReturnError = true
        mockAuthService.customError = NSError(
            domain: ASAuthorizationError.errorDomain,
            code: ASAuthorizationError.canceled.rawValue,
            userInfo: nil
        )
        var onErrorCalled = false
        sut.onError = { _ in onErrorCalled = true }
        sut.deleteAccountWithApple(window: UIWindow())
        let exp = expectation(description: "onLoading false — Task")
        sut.onLoading = { isLoading in
            if !isLoading { exp.fulfill() }
        }
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertFalse(onErrorCalled)
    }
}
