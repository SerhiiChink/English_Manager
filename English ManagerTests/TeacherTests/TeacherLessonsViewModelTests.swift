//
//  TeacherLessonsViewModelTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 16.08.2026.
//

import XCTest
@testable import English_Manager

@MainActor
final class TeacherLessonsViewModelTests: XCTestCase {
    // MARK: - Properties
    private var sut: TeacherLessonsViewModel!
    private var mockAuthService: MockAuthService!
    private var mockFirestoreService: MockFirestoreService!
    private var mockOccurrenceService: MockOccurrenceFirestoreService!

    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
        mockFirestoreService = MockFirestoreService()
        mockOccurrenceService = MockOccurrenceFirestoreService()
        sut = TeacherLessonsViewModel(
            firestoreService: mockFirestoreService,
            authService: mockAuthService,
            occurrenceService: mockOccurrenceService
        )
    }

    override func tearDown() {
        sut = nil
        mockAuthService = nil
        mockFirestoreService = nil
        mockOccurrenceService = nil
        super.tearDown()
    }

    // MARK: - Helpers
    private func makeLesson(
        studentId: String = "student_999",
        teacherId: String = "teacher_123",
        topic: String = "Grammar",
        sourceLinks: [SourceLink] = []
    ) -> Lesson {
        Lesson(
            studentId: studentId,
            teacherId: teacherId,
            occurrenceId: nil,
            studentName: "Anna Smith",
            date: Date(),
            topic: topic,
            bookTitle: "English Grammar in Use",
            pages: "10-12",
            attended: true,
            vocabulary: [],
            sourceLinks: sourceLinks
        )
    }

    private func makeSchedule(
        studentId: String = "student_999",
        teacherId: String = "teacher_123"
    ) -> Schedule {
        Schedule(
            studentId: studentId,
            teacherId: teacherId,
            weekday: 1,
            time: "10:00",
            isActive: true,
            createdAt: Date()
        )
    }

    private func makeOccurrence(
        studentId: String = "student_999",
        teacherId: String = "teacher_123",
        status: OccurrenceStatus = .scheduled
    ) -> LessonOccurrence {
        LessonOccurrence(
            studentId: studentId,
            teacherId: teacherId,
            scheduleId: nil,
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
            email: "a@e.com",
            teacherId: teacherId
        )
        student.role = .student
        return student
    }

    // MARK: - Fetch Tests
    func testFetchLessonsWhenUserNotAuthorizedTriggersError() {
        mockAuthService.currentUserId = nil
        var errorMessage: String?
        sut.onError = { errorMessage = $0 }
        sut.fetchLessons()
        XCTAssertEqual(errorMessage, "The user is not authorized")
    }

    func testFetchLessonsSuccessfullyLoadsData() async throws {
        let teacherId = "teacher_123"
        let studentId = "student_999"
        mockAuthService.currentUserId = teacherId
        mockFirestoreService.users[studentId] = makeStudent(
            id: studentId,
            teacherId: teacherId
        )
        let lesson = makeLesson(studentId: studentId, teacherId: teacherId)
        _ = try await mockFirestoreService.saveLesson(lesson)
        var occurrence = makeOccurrence(studentId: studentId,
                                        teacherId: teacherId,
                                        status: .completed)
        occurrence = try await mockOccurrenceService.saveOccurrence(occurrence)
        let exp = expectation(description: "Fetch completed")
        sut.onUpdate = { exp.fulfill() }
        sut.fetchLessons()
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertEqual(sut.filteredLessons.count, 1)
        XCTAssertEqual(sut.students.count, 1)
        XCTAssertEqual(sut.pendingConfirmations.count, 1)
        XCTAssertEqual(sut.occurrences.count, 1)
    }

    func testFetchLessonsWhenErrorOccursTriggersOnErrorCallback() async {
        mockAuthService.currentUserId = "teacher_123"
        mockFirestoreService.shouldReturnError = true
        let exp = expectation(description: "Fetch error")
        var errorMessage: String?
        sut.onError = { error in
            errorMessage = error
            exp.fulfill()
        }
        sut.fetchLessons()
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertNotNil(errorMessage)
    }

    // MARK: - Add / Update / Delete Lesson Tests
    func testAddLessonSavesAndLinksOccurrence() async throws {
        let lesson = makeLesson(topic: "Speaking")
        var occurrence = makeOccurrence()
        occurrence = try await mockOccurrenceService.saveOccurrence(occurrence)
        let exp = expectation(description: "Add completed")
        sut.onUpdate = { exp.fulfill() }
        sut.addLesson(lesson, occurrence: occurrence)
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertEqual(sut.filteredLessons.first?.topic, "Speaking")
        XCTAssertNotNil(mockOccurrenceService.linkLessonCalledWith?.occurrenceId)
    }

    func testUpdateLessonUpdatesLessonInList() async throws {
        let teacherId = "teacher_123"
        let studentId = "student_999"
        mockAuthService.currentUserId = teacherId
        mockFirestoreService.users[studentId] = makeStudent(
            id: studentId,
            teacherId: teacherId
        )
        let lesson = makeLesson(studentId: studentId,
                                teacherId: teacherId,
                                topic: "Old Topic")
        let saved = try await mockFirestoreService.saveLesson(lesson)
        let fetchExp = expectation(description: "Fetch completed")
        sut.onUpdate = { fetchExp.fulfill() }
        sut.fetchLessons()
        await fulfillment(of: [fetchExp], timeout: 2.0)
        var updatedLesson = saved
        updatedLesson.topic = "New Topic"
        let updateExp = expectation(description: "Update completed")
        sut.onUpdate = { updateExp.fulfill() }
        sut.updateLesson(updatedLesson)
        await fulfillment(of: [updateExp], timeout: 2.0)
        XCTAssertEqual(sut.filteredLessons.first?.topic, "New Topic")
    }

    func testDeleteLessonRemovesLessonAndCallsCompletion() async throws {
        let teacherId = "teacher_123"
        let studentId = "student_999"
        mockAuthService.currentUserId = teacherId
        mockFirestoreService.users[studentId] = makeStudent(
            id: studentId,
            teacherId: teacherId
        )
        let lesson = makeLesson(studentId: studentId, teacherId: teacherId)
        let saved = try await mockFirestoreService.saveLesson(lesson)
        let fetchExp = expectation(description: "Fetch completed")
        sut.onUpdate = { fetchExp.fulfill() }
        sut.fetchLessons()
        await fulfillment(of: [fetchExp], timeout: 2.0)
        XCTAssertEqual(sut.filteredLessons.count, 1)
        var deletedIndex: Int?
        let deleteExp = expectation(description: "Delete completed")
        sut.onUpdate = nil
        sut.deleteLesson(lesson: saved) { index in
            deletedIndex = index
            deleteExp.fulfill()
        }
        await fulfillment(of: [deleteExp], timeout: 2.0)
        XCTAssertNotNil(deletedIndex)
        XCTAssertTrue(sut.filteredLessons.isEmpty)
    }

    func testDeleteRescheduledRemovesOccurrence() async throws {
        let teacherId = "teacher_123"
        let studentId = "student_999"
        mockAuthService.currentUserId = teacherId
        mockFirestoreService.users[studentId] = makeStudent(
            id: studentId,
            teacherId: teacherId
        )
        var occurrence = makeOccurrence(studentId: studentId,
                                        teacherId: teacherId)
        occurrence = try await mockOccurrenceService.saveOccurrence(occurrence)
        let occurrenceId = try XCTUnwrap(occurrence.id)
        let fetchExp = expectation(description: "Fetch completed")
        sut.onUpdate = { fetchExp.fulfill() }
        sut.fetchLessons()
        await fulfillment(of: [fetchExp], timeout: 2.0)
        let deleteExp = expectation(description: "Delete rescheduled completed")
        sut.onUpdate = { deleteExp.fulfill() }
        sut.deleteRescheduled(id: occurrenceId)
        await fulfillment(of: [deleteExp], timeout: 2.0)
        XCTAssertEqual(mockOccurrenceService.deleteOccurrenceCalledWith,
                       occurrenceId)
        XCTAssertTrue(sut.occurrences.isEmpty)
    }

    // MARK: - Schedule Tests
    func testSaveScheduleAddsScheduleToList() async {
        let schedule = makeSchedule()
        let exp = expectation(description: "Save schedule completed")
        var savedResult: Schedule?
        sut.saveSchedule(schedule) { saved in
            savedResult = saved
            exp.fulfill()
        }
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertNotNil(savedResult?.id)
        XCTAssertEqual(sut.schedules(for: "student_999").count, 1)
    }

    func testDeleteScheduleRemovesScheduleFromList() async throws {
        let schedule = makeSchedule()
        let saveExp = expectation(description: "Save completed")
        var saved: Schedule?
        sut.saveSchedule(schedule) { s in
            saved = s
            saveExp.fulfill()
        }
        await fulfillment(of: [saveExp], timeout: 2.0)
        let savedSchedule = try XCTUnwrap(saved)
        let deleteExp = expectation(description: "Delete completed")
        sut.onUpdate = { deleteExp.fulfill() }
        sut.deleteSchedule(savedSchedule)
        await fulfillment(of: [deleteExp], timeout: 2.0)
        XCTAssertTrue(sut.schedules(for: "student_999").isEmpty)
    }

    // MARK: - Filter Tests
    func testCheckDuplicateLinkReturnsMatchingLesson() async throws {
        let teacherId = "teacher_123"
        let studentId = "student_999"
        mockAuthService.currentUserId = teacherId
        mockFirestoreService.users[studentId] = makeStudent(
            id: studentId,
            teacherId: teacherId
        )
        let link = SourceLink(url: "https://example.com", title: "Doc")
        let lesson = makeLesson(studentId: studentId,
                                teacherId: teacherId,
                                sourceLinks: [link])
        _ = try await mockFirestoreService.saveLesson(lesson)
        let fetchExp = expectation(description: "Fetch completed")
        sut.onLoading = { isLoading in
            if !isLoading {
                fetchExp.fulfill()
            }
        }
        sut.fetchLessons()
        await fulfillment(of: [fetchExp], timeout: 2.0)
        let matched = sut.checkDuplicateLink("https://example.com")
        XCTAssertNotNil(matched)
    }

    func testFilterByStudentFiltersLessons() async throws {
        let teacherId = "teacher_123"
        mockAuthService.currentUserId = teacherId
        mockFirestoreService.users["s1"] = makeStudent(
            id: "s1",
            teacherId: teacherId
        )
        mockFirestoreService.users["s2"] = makeStudent(
            id: "s2",
            teacherId: teacherId
        )
        let l1 = makeLesson(studentId: "s1", teacherId: teacherId)
        let l2 = makeLesson(studentId: "s2", teacherId: teacherId)
        _ = try await mockFirestoreService.saveLesson(l1)
        _ = try await mockFirestoreService.saveLesson(l2)
        let fetchExp = expectation(description: "Fetch completed")
        sut.onUpdate = { fetchExp.fulfill() }
        sut.fetchLessons()
        await fulfillment(of: [fetchExp], timeout: 2.0)
        sut.onUpdate = nil
        sut.filterByStudent("s1")
        XCTAssertEqual(sut.filteredLessons.count, 1)
        XCTAssertEqual(sut.filteredLessons.first?.studentId, "s1")
    }
}
