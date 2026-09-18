//
//  StudentsViewModelTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 16.08.2026.
//

import XCTest
@testable import English_Manager

@MainActor
final class StudentsViewModelTests: XCTestCase {
    // MARK: - Properties
    private var sut: StudentsViewModel!
    private var mockAuthService: MockAuthService!
    private var mockFirestoreService: MockFirestoreService!

    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
        mockFirestoreService = MockFirestoreService()
        sut = StudentsViewModel(
            firestoreService: mockFirestoreService,
            authService: mockAuthService
        )
    }

    override func tearDown() {
        sut = nil
        mockAuthService = nil
        mockFirestoreService = nil
        super.tearDown()
    }

    // MARK: - Helpers
    private func makeStudent(
        id: String = "student_999",
        email: String = "student@test.com",
        teacherId: String? = nil
    ) -> User {
        var student = User(
            id: id,
            name: "Anna",
            surname: "Smith",
            email: email,
            teacherId: teacherId
        )
        student.role = .student
        return student
    }

    // MARK: - Fetch Tests
    func testFetchStudentsWhenUserNotFoundTriggersError() {
        mockAuthService.currentUserId = nil
        var errorMessage: String?
        sut.onError = { errorMessage = $0 }
        sut.fetchStudents()
        XCTAssertEqual(errorMessage, "User not found")
        XCTAssertTrue(sut.students.isEmpty)
    }

    func testFetchStudentsSuccessfullyLoadsData() async {
        let teacherId = "teacher_123"
        mockAuthService.currentUserId = teacherId
        let student = makeStudent(id: "s1", teacherId: teacherId)
        mockFirestoreService.users[student.id] = student
        let exp = expectation(description: "Fetch completed")
        sut.onUpdate = { exp.fulfill() }
        sut.fetchStudents()
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertEqual(sut.students.count, 1)
        XCTAssertEqual(sut.students.first?.id, "s1")
    }

    func testFetchStudentsWhenErrorOccursTriggersOnErrorCallback() async {
        mockAuthService.currentUserId = "teacher_123"
        mockFirestoreService.shouldReturnError = true
        let exp = expectation(description: "Fetch error")
        var errorMessage: String?
        sut.onError = { error in
            errorMessage = error
            exp.fulfill()
        }
        sut.fetchStudents()
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertNotNil(errorMessage)
        XCTAssertTrue(sut.students.isEmpty)
    }

    // MARK: - Add Student Tests
    func testAddStudentSuccessfullyLinksTeacherAndRefetchesStudents() async {
        let teacherId = "teacher_123"
        let studentEmail = "new_student@test.com"
        mockAuthService.currentUserId = teacherId
        var student = makeStudent(id: "s_new",
                                  email: studentEmail,
                                  teacherId: nil)
        student.role = .student
        mockFirestoreService.users[student.id] = student
        let exp = expectation(description: "fetchStudents after add completed")
        exp.expectedFulfillmentCount = 1
        sut.onUpdate = { exp.fulfill() }
        sut.addStudent(email: studentEmail)
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertEqual(sut.students.count, 1)
        XCTAssertEqual(sut.students.first?.email, studentEmail)
        XCTAssertEqual(mockFirestoreService.users["s_new"]?.teacherId, teacherId)
    }

    func testAddStudentWhenUserNotFoundTriggersError() async {
        mockAuthService.currentUserId = "teacher_123"
        let exp = expectation(description: "User not found error")
        var errorMessage: String?
        sut.onError = { error in
            errorMessage = error
            exp.fulfill()
        }
        sut.addStudent(email: "nonexistent@test.com")
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertEqual(errorMessage, "User not found")
    }

    func testAddStudentWhenStudentAlreadyHasTeacherTriggersError() async {
        let teacherId = "teacher_123"
        let studentEmail = "busy_student@test.com"
        mockAuthService.currentUserId = teacherId
        let student = makeStudent(id: "s_busy",
                                  email: studentEmail,
                                  teacherId: "other_teacher_456")
        mockFirestoreService.users[student.id] = student
        let exp = expectation(description: "Already has teacher error")
        var errorMessage: String?
        sut.onError = { error in
            errorMessage = error
            exp.fulfill()
        }
        sut.addStudent(email: studentEmail)
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertEqual(errorMessage, "Student already has a teacher")
    }

    // MARK: - Remove Student Tests
    func testRemoveStudentRemovesFromListAndFirestore() async throws {
        let teacherId = "teacher_123"
        mockAuthService.currentUserId = teacherId
        let student = makeStudent(id: "s1", teacherId: teacherId)
        mockFirestoreService.users[student.id] = student
        let fetchExp = expectation(description: "Fetch completed")
        sut.onUpdate = { fetchExp.fulfill() }
        sut.fetchStudents()
        await fulfillment(of: [fetchExp], timeout: 2.0)
        let removeExp = expectation(description: "Remove completed")
        sut.onUpdate = { removeExp.fulfill() }
        sut.removeStudent(student)
        await fulfillment(of: [removeExp], timeout: 2.0)
        XCTAssertEqual(mockFirestoreService.removeStudentCalledWith, "s1")
        XCTAssertTrue(sut.students.isEmpty)
    }

    func testRemoveStudentWhenErrorOccursTriggersOnErrorCallback() async {
        let student = makeStudent(id: "s1")
        mockFirestoreService.shouldReturnError = true
        let exp = expectation(description: "Remove error")
        var errorMessage: String?
        sut.onError = { error in
            errorMessage = error
            exp.fulfill()
        }
        sut.removeStudent(student)
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertNotNil(errorMessage)
    }
}
