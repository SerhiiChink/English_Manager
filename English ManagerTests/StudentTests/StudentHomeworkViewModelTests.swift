//
//  StudentHomeworkViewModelTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 15.08.2026.
//

import XCTest
@testable import English_Manager

@MainActor
final class StudentHomeworkViewModelTests: XCTestCase {
    // MARK: - Properties
    private var sut: StudentHomeworkViewModel!
    private var mockAuthService: MockAuthService!
    private var mockFirestoreService: MockFirestoreService!
    private var mockHomeworkService: MockHomeworkFirestoreService!
    private var mockUserCache: MockUserCache!
    
    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
        mockFirestoreService = MockFirestoreService()
        mockHomeworkService = MockHomeworkFirestoreService()
        mockUserCache = MockUserCache()
        sut = StudentHomeworkViewModel(
            homeworkService: mockHomeworkService,
            firestoreService: mockFirestoreService,
            authService: mockAuthService,
            cache: mockUserCache
        )
    }

    override func tearDown() {
        sut = nil
        mockAuthService = nil
        mockFirestoreService = nil
        mockHomeworkService = nil
        mockUserCache = nil
        super.tearDown()
    }
    
    // MARK: - Fetch Tests
    func testFetchHomeworksWhenUserNotLoggedInTriggersError() {
        mockAuthService.currentUserId = nil
        var errorMessage: String?
        sut.onError = { error in
            errorMessage = error
        }
        sut.fetchHomeworks()
        XCTAssertEqual(errorMessage, "User not found")
    }

    func testFetchHomeworksSuccessfullyLoadsData() {
        let studentId = "student_123"
        mockAuthService.currentUserId = studentId
        let student = User(id: studentId,
                           name: "Anna",
                           surname: "Smith",
                           email: "a@e.com")
        mockFirestoreService.users[studentId] = student
        let exp = expectation(description: "Fetch completed")
        sut.onUpdate = {
            exp.fulfill()
        }
        sut.fetchHomeworks()
        wait(for: [exp], timeout: 1.0)
        XCTAssertTrue(sut.homeworks.isEmpty)
    }

    // MARK: - Add Homework Tests
    func testAddHomeworkWhenNoTeacherTriggersError() async {
        let studentId = "student_123"
        mockAuthService.currentUserId = studentId
        let studentWithoutTeacher = User(
            id: studentId,
            name: "Anna",
            surname: "Smith",
            email: "a@e.com",
            teacherId: nil
        )
        mockFirestoreService.users[studentId] = studentWithoutTeacher
        let fetchExp = expectation(description: "Fetch completed")
        sut.onUpdate = { fetchExp.fulfill() }
        sut.fetchHomeworks()
        await fulfillment(of: [fetchExp], timeout: 1.0)
        var errorMessage: String?
        sut.onError = { error in
            errorMessage = error
        }
        sut.addHomework(title: "Task 1",
                        description: "Read book",
                        link: "https://example.com")
        XCTAssertEqual(errorMessage,
                       "No teacher assigned. Contact your teacher to link accounts.")
    }

    // MARK: - Delete Homework Tests
    func testDeleteHomeworkRemovesItemFromList() {
        let studentId = "student_123"
        mockAuthService.currentUserId = studentId
        let student = User(id: studentId,
                           name: "Anna",
                           surname: "Smith",
                           email: "a@e.com")
        mockFirestoreService.users[studentId] = student
        var homework = Homework(
            studentId: studentId,
            teacherId: "teacher_1",
            lessonId: nil,
            studentName: "Anna Smith",
            title: "Task 1",
            description: "Read",
            sourceLink: "",
            status: .pending,
            grade: nil,
            teacherFeedback: nil,
            createdAt: Date(),
            reviewedAt: nil
        )
        homework.id = "hw_123"
        mockHomeworkService.homeworks["hw_123"] = homework
        let fetchExp = expectation(description: "Fetch completed")
        sut.onUpdate = { fetchExp.fulfill() }
        sut.fetchHomeworks()
        wait(for: [fetchExp], timeout: 1.0)
        let deleteExp = expectation(description: "Delete completed")
        var deletedIndex: Int?
        sut.deleteHomework(homework) { index in
            deletedIndex = index
            deleteExp.fulfill()
        }
        wait(for: [deleteExp], timeout: 1.0)
        XCTAssertEqual(deletedIndex, 0)
        XCTAssertTrue(sut.homeworks.isEmpty)
    }
}
