//
//  LessonOccurrenceViewModelTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 16.08.2026.
//

import XCTest
@testable import English_Manager

@MainActor
final class LessonOccurrenceViewModelTests: XCTestCase {
    // MARK: - Properties
    private var sut: LessonOccurrenceViewModel!
    private var mockAuthService: MockAuthService!
    private var mockOccurrenceService: MockOccurrenceFirestoreService!

    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
        mockOccurrenceService = MockOccurrenceFirestoreService()
        sut = LessonOccurrenceViewModel(
            occurrenceService: mockOccurrenceService,
            authService: mockAuthService
        )
    }

    override func tearDown() {
        sut = nil
        mockAuthService = nil
        mockOccurrenceService = nil
        super.tearDown()
    }

    // MARK: - Helpers
    private func makeOccurrence(
        id: String? = nil,
        studentId: String = "mock_user_id",
        teacherId: String = "teacher_123",
        scheduledAt: Date = Date(),
        status: OccurrenceStatus = .scheduled
    ) -> LessonOccurrence {
        LessonOccurrence(
            id: id,
            studentId: studentId,
            teacherId: teacherId,
            scheduleId: nil,
            scheduledAt: scheduledAt,
            status: status,
            cancelledBy: nil,
            cancelledAt: nil,
            notifiedAt: nil,
            lessonId: nil
        )
    }

    // MARK: - Fetch Tests
    func testFetchTodayOccurrencesWhenUserNotAuthenticatedTriggersError() {
        mockAuthService.currentUserId = nil
        var errorMessage: String?
        sut.onError = { errorMessage = $0 }
        sut.fetchTodayOccurrences()
        XCTAssertEqual(errorMessage, "User not authenticated")
        XCTAssertTrue(sut.todayOccurrences.isEmpty)
    }

    func testFetchTodayOccurrencesSuccessfullyLoadsData() async throws {
        let userId = "student_123"
        mockAuthService.currentUserId = userId
        let todayOccurrence = makeOccurrence(studentId: userId, scheduledAt: Date())
        _ = try await mockOccurrenceService.saveOccurrence(todayOccurrence)
        let exp = expectation(description: "Fetch completed")
        sut.onUpdate = { exp.fulfill() }
        sut.fetchTodayOccurrences()
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertEqual(sut.todayOccurrences.count, 1)
        XCTAssertEqual(sut.todayOccurrences.first?.studentId, userId)
    }

    func testFetchTodayOccurrencesWhenErrorOccursTriggersOnErrorCallback() async {
        mockAuthService.currentUserId = "student_123"
        mockOccurrenceService.shouldReturnError = true
        let exp = expectation(description: "Fetch error")
        var errorMessage: String?
        sut.onError = { error in
            errorMessage = error
            exp.fulfill()
        }
        sut.fetchTodayOccurrences()
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertNotNil(errorMessage)
        XCTAssertTrue(sut.todayOccurrences.isEmpty)
    }

    // MARK: - Cancel Tests
    func testCancelOccurrencesSuccessfullyCancelsAndRefetchesData() async throws {
        let userId = "student_123"
        mockAuthService.currentUserId = userId
        var occurrence = makeOccurrence(studentId: userId, scheduledAt: Date())
        occurrence = try await mockOccurrenceService.saveOccurrence(occurrence)
        let occurrenceId = try XCTUnwrap(occurrence.id)
        let exp = expectation(description: "Cancel completed")
        sut.onUpdate = { exp.fulfill() }
        sut.cancelOccurrences(occurrence, by: .student)
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertEqual(mockOccurrenceService.cancelOccurrenceCalledWith?.id,
                       occurrenceId)
        XCTAssertEqual(mockOccurrenceService.cancelOccurrenceCalledWith?.cancelledBy, .student)
        XCTAssertEqual(sut.todayOccurrences.count, 1)
        XCTAssertEqual(sut.todayOccurrences.first?.status, .cancelled)
    }

    func testCancelOccurrencesWhenErrorOccursTriggersOnErrorCallback() async throws {
        let userId = "student_123"
        mockAuthService.currentUserId = userId
        var occurrence = makeOccurrence(studentId: userId)
        occurrence = try await mockOccurrenceService.saveOccurrence(occurrence)
        mockOccurrenceService.shouldReturnError = true
        let exp = expectation(description: "Cancel error")
        var errorMessage: String?
        sut.onError = { error in
            errorMessage = error
            exp.fulfill()
        }
        sut.cancelOccurrences(occurrence, by: .student)
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertNotNil(errorMessage)
    }
}
