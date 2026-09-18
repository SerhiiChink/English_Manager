//
//  LessonConfirmationViewModelTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 16.08.2026.
//

import XCTest
@testable import English_Manager

@MainActor
final class LessonConfirmationViewModelTests: XCTestCase {
    // MARK: - Properties
    private var sut: LessonConfirmationViewModel!
    private var mockOccurrenceService: MockOccurrenceFirestoreService!

    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        mockOccurrenceService = MockOccurrenceFirestoreService()
    }

    override func tearDown() {
        sut = nil
        mockOccurrenceService = nil
        super.tearDown()
    }

    // MARK: - Helpers
    private func makeOccurrence(
        id: String = "occurrence_123",
        studentId: String = "student_999",
        teacherId: String = "teacher_123",
        status: OccurrenceStatus = .completed
    ) -> LessonOccurrence {
        LessonOccurrence(
            id: id,
            studentId: studentId,
            teacherId: teacherId,
            scheduleId: "schedule_001",
            scheduledAt: Date(),
            status: status,
            cancelledBy: nil,
            cancelledAt: nil,
            notifiedAt: nil,
            lessonId: nil
        )
    }

    private func makeStudent(
        id: String = "student_999",
        teacherId: String = "teacher_123"
    ) -> User {
        var student = User(
            id: id,
            name: "Anna",
            surname: "Smith",
            email: "anna@test.com",
            teacherId: teacherId
        )
        student.role = .student
        return student
    }

    private func createSUT(
        occurrence: LessonOccurrence? = nil,
        student: User? = nil
    ) -> LessonConfirmationViewModel {
        LessonConfirmationViewModel(
            occurrence: occurrence ?? makeOccurrence(),
            student: student ?? makeStudent(),
            occurrenceService: mockOccurrenceService
        )
    }

    // MARK: - Charge Lesson Tests
    func testChargeLessonResolvesOccurrenceWithChargedStatus() async {
        let occurrence = makeOccurrence(id: "occ_charge")
        sut = createSUT(occurrence: occurrence)
        let exp = expectation(description: "OnDismiss called")
        sut.onDismiss = { exp.fulfill() }
        sut.chargeLesson()
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertEqual(mockOccurrenceService.resolveOccurrenceCalledWith?.id,
                       "occ_charge")
        XCTAssertEqual(mockOccurrenceService.resolveOccurrenceCalledWith?.status, .charged)
    }

    func testChargeLessonWhenErrorOccursTriggersOnErrorCallback() async {
        sut = createSUT()
        mockOccurrenceService.shouldReturnError = true
        let exp = expectation(description: "OnError called")
        var errorMessage: String?
        sut.onError = { error in
            errorMessage = error
            exp.fulfill()
        }
        sut.chargeLesson()
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertNotNil(errorMessage)
    }

    // MARK: - Missed Lesson Tests
    func testMissedLessonResolvesOccurrenceWithMissedStatus() async {
        let occurrence = makeOccurrence(id: "occ_missed")
        sut = createSUT(occurrence: occurrence)
        let exp = expectation(description: "OnDismiss called")
        sut.onDismiss = { exp.fulfill() }
        sut.missedLesson()
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertEqual(mockOccurrenceService.resolveOccurrenceCalledWith?.id,
                       "occ_missed")
        XCTAssertEqual(mockOccurrenceService.resolveOccurrenceCalledWith?.status, .missed)
    }

    // MARK: - Cancel Lesson Tests
    func testCancelLessonWithoutCustomDateResolvesAsCancelled() async {
        let occurrence = makeOccurrence(id: "occ_cancel")
        sut = createSUT(occurrence: occurrence)
        let exp = expectation(description: "OnDismiss called")
        sut.onDismiss = { exp.fulfill() }
        sut.cancelLesson(customDate: nil)
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertEqual(mockOccurrenceService.resolveOccurrenceCalledWith?.id,
                       "occ_cancel")
        XCTAssertEqual(mockOccurrenceService.resolveOccurrenceCalledWith?.status, .cancelled)
        XCTAssertFalse(mockOccurrenceService.createOneTimeOccurrenceCalled)
    }

    func testCancelLessonWithCustomDateCreatesOneTimeOccurrenceAndCancelsCurrent() async {
        let occurrence = makeOccurrence(id: "occ_reschedule")
        sut = createSUT(occurrence: occurrence)
        let customDate = Calendar.current.date(byAdding: .day,
                                               value: 2,
                                               to: Date())!
        let exp = expectation(description: "OnDismiss called")
        sut.onDismiss = { exp.fulfill() }
        sut.cancelLesson(customDate: customDate)
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertTrue(mockOccurrenceService.createOneTimeOccurrenceCalled)
        XCTAssertEqual(mockOccurrenceService.resolveOccurrenceCalledWith?.id,
                       "occ_reschedule")
        XCTAssertEqual(mockOccurrenceService.resolveOccurrenceCalledWith?.status, .cancelled)
    }

    func testCancelLessonWhenErrorOccursTriggersOnErrorCallback() async {
        sut = createSUT()
        mockOccurrenceService.shouldReturnError = true
        let exp = expectation(description: "OnError called")
        var errorMessage: String?
        sut.onError = { error in
            errorMessage = error
            exp.fulfill()
        }
        sut.cancelLesson(customDate: nil)
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertNotNil(errorMessage)
    }
}
