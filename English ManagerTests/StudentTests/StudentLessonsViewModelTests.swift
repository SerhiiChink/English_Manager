//
//  StudentLessonsViewModelTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 15.08.2026.
//

import XCTest
@testable import English_Manager

@MainActor
final class StudentLessonsViewModelTests: XCTestCase {
    // MARK: - Properties
    private var sut: StudentLessonsViewModel!
    private var mockAuthService: MockAuthService!
    private var mockFirestoreService: MockFirestoreService!
    private var mockOccurrenceService: MockOccurrenceFirestoreService!
    private var mockUserCache: MockUserCache!
    
    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
        mockFirestoreService = MockFirestoreService()
        mockOccurrenceService = MockOccurrenceFirestoreService()
        mockUserCache = MockUserCache()
        sut = StudentLessonsViewModel(
            firestoreService: mockFirestoreService,
            authService: mockAuthService,
            occurrenceService: mockOccurrenceService,
            cache: mockUserCache
        )
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(
            forKey: UDKeys.lastTeacherId(for: "student_123")
        )
        sut = nil
        mockAuthService = nil
        mockFirestoreService = nil
        mockOccurrenceService = nil
        mockUserCache = nil
        super.tearDown()
    }
    
    // MARK: - Error Handling Tests
    func testFetchLessonsWhenUserNotLoggedInTriggersError() {
        mockAuthService.currentUserId = nil
        var errorMessage: String?
        sut.onError = { errorMessage = $0 }
        sut.fetchLessons()
        XCTAssertEqual(errorMessage, "User not found")
    }
 
    func testFetchLessonsWhenFirestoreFailsTriggersError() async {
        mockAuthService.currentUserId = "student_123"
        mockFirestoreService.shouldReturnError = true
        let exp = expectation(description: "Error triggered")
        var errorMessage: String?
        sut.onError = { error in
            errorMessage = error
            exp.fulfill()
        }
        sut.fetchLessons()
        await fulfillment(of: [exp], timeout: 1.0)
        XCTAssertNotNil(errorMessage)
    }
 
    // MARK: - No Teacher Scenario
    func testFetchLessonsWhenUserHasNoTeacherClearsDataAndNotifies() async {
        let studentId = "student_123"
        mockAuthService.currentUserId = studentId
        mockFirestoreService.users[studentId] = User(
            id: studentId,
            name: "Anna",
            surname: "Smith",
            email: "anna@example.com",
            teacherId: nil
        )
        var updateCalled = false
        let exp = expectation(description: "Update triggered")
        sut.onUpdate = {
            updateCalled = true
            exp.fulfill()
        }
        sut.fetchLessons()
        await fulfillment(of: [exp], timeout: 1.0)
        XCTAssertTrue(updateCalled)
        XCTAssertNil(sut.teacherName)
        XCTAssertNil(sut.teacherTimezone)
        XCTAssertTrue(sut.lessons.isEmpty)
        XCTAssertNil(UserDefaults.standard.string(
            forKey: UDKeys.lastTeacherId(for: studentId)
        ))
    }
 
    // MARK: - Success Fetch Tests
    func testFetchLessonsSuccessfullyLoadsDataAndTriggersCallbacks() async {
        let studentId = "student_123"
        let teacherId = "teacher_999"
        mockAuthService.currentUserId = studentId
        var teacher = User(
            id: teacherId,
            name: "John",
            surname: "Doe",
            email: "teacher@example.com"
        )
        teacher.timezone = "Europe/Kyiv"
        let student = User(
            id: studentId,
            name: "Anna",
            surname: "Smith",
            email: "anna@example.com",
            teacherId: teacherId
        )
//        mockFirestoreService.users[studentId] = User(
//            id: studentId,
//            name: "Anna",
//            surname: "Smith",
//            email: "anna@example.com",
//            teacherId: teacherId
//        )
        mockFirestoreService.users[studentId] = student
        mockFirestoreService.users[teacherId] = teacher
        mockUserCache.users[studentId] = student
        mockUserCache.users[teacherId] = teacher
        UserDefaults.standard.removeObject(
            forKey: UDKeys.lastTeacherId(for: studentId)
        )
        var loadingStates: [Bool] = []
        let expUpdate = expectation(description: "Update triggered")
        let expTeacherAssigned = expectation(description: "Teacher assigned")
        sut.onLoading = { loadingStates.append($0) }
        sut.onTeacherAssigned = { expTeacherAssigned.fulfill() }
        sut.onUpdate = { expUpdate.fulfill() }
        sut.fetchLessons()
        await fulfillment(of: [expUpdate, expTeacherAssigned],
                          timeout: 2.0,
                          enforceOrder: false)
        XCTAssertEqual(sut.teacherName, teacher.shortName)
        XCTAssertEqual(sut.teacherTimezone, "Europe/Kyiv")
        XCTAssertEqual(loadingStates, [true, false])
    }
 
    // MARK: - Rescheduled Lessons Computed Property
    func testRescheduledLessonsFiltersOccurrencesCorrectly() async {
        let studentId = "student_123"
        let teacherId = "teacher_999"
        mockAuthService.currentUserId = studentId
        mockFirestoreService.users[studentId] = User(
            id: studentId,
            name: "Anna",
            surname: "Smith",
            email: "a@e.com",
            teacherId: teacherId
        )
        mockFirestoreService.users[teacherId] = User(
            id: teacherId,
            name: "John",
            surname: "Doe",
            email: "t@e.com"
        )
        var rescheduled = LessonOccurrence(
            studentId: studentId,
            teacherId: teacherId,
            scheduleId: nil,
            scheduledAt: Date(),
            status: .scheduled,
            cancelledBy: nil,
            cancelledAt: nil,
            notifiedAt: nil,
            lessonId: nil
        )
        rescheduled.id = "occ_1"
        var regular = LessonOccurrence(
            studentId: studentId,
            teacherId: teacherId,
            scheduleId: "sch_1",
            scheduledAt: Date(),
            status: .scheduled,
            cancelledBy: nil,
            cancelledAt: nil,
            notifiedAt: nil,
            lessonId: nil
        )
        regular.id = "occ_2"
        mockOccurrenceService.occurrences["occ_1"] = rescheduled
        mockOccurrenceService.occurrences["occ_2"] = regular
        let exp = expectation(description: "Fetch completed")
        sut.onUpdate = { exp.fulfill() }
        sut.fetchLessons()
        await fulfillment(of: [exp], timeout: 1.0)
        XCTAssertEqual(sut.rescheduledLessons.count, 1)
        XCTAssertEqual(sut.rescheduledLessons.first?.id, "occ_1")
    }
}
 
