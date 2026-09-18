//
//  TeacherHomeworkViewModelTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 15.09.2026.
//

import XCTest
@testable import English_Manager

@MainActor
final class TeacherHomeworkViewModelTests: XCTestCase {
    // MARK: - Properties
    private var sut: TeacherHomeworkViewModel!
    private var mockAuthService: MockAuthService!
    private var mockHomeworkService: MockHomeworkFirestoreService!

    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
        mockHomeworkService = MockHomeworkFirestoreService()
        sut = TeacherHomeworkViewModel(
            homeworkService: mockHomeworkService,
            authService: mockAuthService
        )
    }

    override func tearDown() {
        sut = nil
        mockAuthService = nil
        mockHomeworkService = nil
        super.tearDown()
    }

    // MARK: - Helpers
    private func makeHomework(
        id: String = "hw_123",
        teacherId: String = "teacher_123",
        studentName: String = "Anna Smith",
        status: HomeworkStatus = .pending
    ) -> Homework {
        var hw = Homework(
            studentId: "student_999",
            teacherId: teacherId,
            lessonId: nil,
            studentName: studentName,
            title: "Grammar Exercise",
            description: "Do exercise 5",
            sourceLink: "",
            status: status,
            createdAt: Date()
        )
        hw.id = id
        return hw
    }

    // MARK: - Fetch Homework Tests
    func testFetchHomeworkWhenUserNotLoggedInTriggersError() {
        mockAuthService.currentUserId = nil
        var errorMessage: String?
        sut.onError = { errorMessage = $0 }
        sut.fetchHomework()
        XCTAssertEqual(errorMessage, "User not found")
    }

    func testFetchHomeworkSuccessLoadsDataAndTriggersCallbacks() async {
        let teacherId = "teacher_123"
        mockAuthService.currentUserId = teacherId
        let hw1 = makeHomework(id: "hw_1",
                               teacherId: teacherId,
                               studentName: "Anna Smith")
        let hw2 = makeHomework(id: "hw_2",
                               teacherId: teacherId,
                               studentName: "John Doe")
        mockHomeworkService.homeworks["hw_1"] = hw1
        mockHomeworkService.homeworks["hw_2"] = hw2
        var loadingStates: [Bool] = []
        let expUpdate = expectation(description: "Fetch completed")
        sut.onLoading = { loadingStates.append($0) }
        sut.onUpdate = { expUpdate.fulfill() }
        sut.fetchHomework()
        await fulfillment(of: [expUpdate], timeout: 2.0)
        XCTAssertEqual(sut.filteredHomeworks.count, 2)
        XCTAssertEqual(sut.students, ["Anna Smith", "John Doe"])
        XCTAssertEqual(loadingStates, [true, false])
    }

    func testFetchHomeworkWhenErrorOccursTriggersOnErrorCallback() async {
        mockAuthService.currentUserId = "teacher_123"
        mockHomeworkService.shouldReturnError = true
        let expError = expectation(description: "Fetch error")
        var errorMessage: String?
        sut.onError = { error in
            errorMessage = error
            expError.fulfill()
        }
        sut.fetchHomework()
        await fulfillment(of: [expError], timeout: 2.0)
        XCTAssertNotNil(errorMessage)
    }

    func testFetchHomeworkPreventsConcurrentRequests() async {
        let teacherId = "teacher_123"
        mockAuthService.currentUserId = teacherId
        mockHomeworkService.homeworks["hw_1"] = makeHomework(
            id: "hw_1",
            teacherId: teacherId
        )
        var updateCount = 0
        let exp = expectation(description: "Update called once")
        sut.onUpdate = {
            updateCount += 1
            exp.fulfill()
        }
        sut.fetchHomework()
        sut.fetchHomework()
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertEqual(updateCount, 1)
    }

    // MARK: - Review Homework Tests
    func testReviewHomeworkSuccessUpdatesHomeworkStatusAndTriggersCallbacks() async {
        let teacherId = "teacher_123"
        mockAuthService.currentUserId = teacherId
        let originalHw = makeHomework(id: "hw_1", teacherId: teacherId)
        mockHomeworkService.homeworks["hw_1"] = originalHw
        let fetchExp = expectation(description: "Fetch completed")
        sut.onUpdate = { fetchExp.fulfill() }
        sut.fetchHomework()
        await fulfillment(of: [fetchExp], timeout: 2.0)
        var loadingStates: [Bool] = []
        let reviewExp = expectation(description: "Review completed")
        sut.onLoading = { loadingStates.append($0) }
        sut.onUpdate = { reviewExp.fulfill() }
        sut.reviewHomework(originalHw, grade: 5, feedback: "Great job!")
        await fulfillment(of: [reviewExp], timeout: 2.0)
        let updatedHw = sut.filteredHomeworks.first
        XCTAssertEqual(updatedHw?.status, .reviewed)
        XCTAssertEqual(updatedHw?.grade, 5)
        XCTAssertEqual(updatedHw?.teacherFeedback, "Great job!")
        XCTAssertNotNil(updatedHw?.reviewedAt)
        XCTAssertEqual(loadingStates, [true, false])
    }

    func testReviewHomeworkWhenErrorOccursTriggersOnErrorCallback() async {
        let hw = makeHomework(id: "hw_1")
        mockHomeworkService.shouldReturnError = true
        let expError = expectation(description: "Review error")
        var errorMessage: String?
        sut.onError = { error in
            errorMessage = error
            expError.fulfill()
        }
        sut.reviewHomework(hw, grade: 4, feedback: "Good")
        await fulfillment(of: [expError], timeout: 2.0)
        XCTAssertNotNil(errorMessage)
    }

    // MARK: - Filter Tests
    func testFilterByStudentFiltersHomeworksAndTriggersUpdate() async {
        let teacherId = "teacher_123"
        mockAuthService.currentUserId = teacherId
        let hw1 = makeHomework(id: "hw_1",
                               teacherId: teacherId,
                               studentName: "Anna Smith")
        let hw2 = makeHomework(id: "hw_2",
                               teacherId: teacherId,
                               studentName: "John Doe")
        mockHomeworkService.homeworks["hw_1"] = hw1
        mockHomeworkService.homeworks["hw_2"] = hw2
        let fetchExp = expectation(description: "Fetch completed")
        sut.onUpdate = { fetchExp.fulfill() }
        sut.fetchHomework()
        await fulfillment(of: [fetchExp], timeout: 2.0)
        var updateCalled = false
        sut.onUpdate = { updateCalled = true }
        sut.filterByStudent("Anna Smith")
        XCTAssertTrue(updateCalled)
        XCTAssertEqual(sut.filteredHomeworks.count, 1)
        XCTAssertEqual(sut.filteredHomeworks.first?.studentName, "Anna Smith")
        sut.filterByStudent(nil)
        XCTAssertEqual(sut.filteredHomeworks.count, 2)
    }

    // MARK: - Cell Model Tests
    func testCellModelReturnsValidHomeworkCellModel() {
        let hw = makeHomework(id: "hw_1", studentName: "Anna Smith")
        let cellModel = sut.cellModel(for: hw)
        XCTAssertEqual(cellModel.studentName, "Anna Smith")
    }
}
