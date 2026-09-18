//
//  FirestoreServiceTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 15.08.2026.
//

import XCTest
@testable import English_Manager

@MainActor
final class FirestoreServiceTests: XCTestCase {
    // MARK: - Properties
    private var sut: MockFirestoreService!
    
    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        sut = MockFirestoreService()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Users Tests
    func testSaveUserAndFetchUserSuccess() async throws {
        let user = User(
            id: "user_123",
            name: "John",
            surname: "Doe",
            email: "student@example.com",
            role: .student
        )
        try await sut.saveUser(user)
        let fetchedUser = try await sut.fetchUser(id: "user_123")
        XCTAssertTrue(sut.saveUserCalled)
        XCTAssertEqual(fetchedUser.id, user.id)
        XCTAssertEqual(fetchedUser.email, user.email)
        XCTAssertEqual(fetchedUser.name, "John")
        XCTAssertEqual(fetchedUser.role, .student)
    }
    
    func testFetchUserNotFoundThrowsError() async throws {
        do {
            _ = try await sut.fetchUser(id: "non_existent_id")
            XCTFail("Expected fetchUser to throw an error, but it succeeded")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func testUpdateUserProfileUpdatesNameAndSurname() async throws {
        let user = User(
            id: "user_123",
            name: "OldName",
            surname: "OldSurname",
            email: "test@example.com",
            role: .student
        )
        try await sut.saveUser(user)
        try await sut.updateUserProfile(userId: "user_123", name: "NewName", surname: "NewSurname")
        let updatedUser = try await sut.fetchUser(id: "user_123")
        XCTAssertEqual(updatedUser.name, "NewName")
        XCTAssertEqual(updatedUser.surname, "NewSurname")
    }
    
    func testFindUserByEmailReturnsStudent() async throws {
        let student = User(
            id: "s_1",
            name: "Student",
            surname: "One",
            email: "student@test.com",
            role: .student
        )
        let teacher = User(
            id: "t_1",
            name: "Teacher",
            surname: "One",
            email: "teacher@test.com",
            role: .teacher
        )
        try await sut.saveUser(student)
        try await sut.saveUser(teacher)
        let foundStudent = try await sut.findUserByEmail("student@test.com")
        let foundTeacherAsStudent = try await sut.findUserByEmail("teacher@test.com")
        XCTAssertEqual(foundStudent?.id, "s_1")
        XCTAssertNil(foundTeacherAsStudent)
    }
    
    func testUpdateFCMTokenUpdatesTokenCorrectly() async throws {
        let user = User(
            id: "user_123",
            name: "Test",
            surname: "User",
            email: "test@example.com",
            role: .student
        )
        try await sut.saveUser(user)
        try await sut.updateFCMToken(userId: "user_123", token: "sample_fcm_token_999")
        let updatedUser = try await sut.fetchUser(id: "user_123")
        XCTAssertEqual(sut.updateFCMTokenCalledWith?.userId, "user_123")
        XCTAssertEqual(sut.updateFCMTokenCalledWith?.token, "sample_fcm_token_999")
        XCTAssertEqual(updatedUser.fcmToken, "sample_fcm_token_999")
    }
    
    // MARK: - Lessons Tests
    func testSaveLessonAndFetchLessonsSuccess() async throws {
        let lesson = Lesson(
            id: "lesson_1",
            studentId: "student_1",
            teacherId: "teacher_1",
            occurrenceId: nil,
            studentName: "John Doe",
            date: Date(),
            topic: "Grammar",
            bookTitle: "English File",
            pages: "12-15",
            attended: true,
            vocabulary: [],
            sourceLinks: []
        )
        let savedLesson = try await sut.saveLesson(lesson)
        let teacherLessons = try await sut.fetchLessons(teacherId: "teacher_1")
        let studentLessons = try await sut.fetchStudentLessons(studentId: "student_1")
        XCTAssertEqual(savedLesson.id, "lesson_1")
        XCTAssertEqual(teacherLessons.count, 1)
        XCTAssertEqual(studentLessons.count, 1)
        XCTAssertEqual(teacherLessons.first?.id, "lesson_1")
    }
    
    func testDeleteLessonRemovesLessonFromStorage() async throws {
        let lesson = Lesson(
            id: "lesson_to_delete",
            studentId: "student_1",
            teacherId: "teacher_1",
            occurrenceId: nil,
            studentName: "John Doe",
            date: Date(),
            topic: "Vocabulary",
            bookTitle: "",
            pages: "",
            attended: true,
            vocabulary: [],
            sourceLinks: []
        )
        _ = try await sut.saveLesson(lesson)
        try await sut.deleteLesson(id: "lesson_to_delete")
        let lessons = try await sut.fetchLessons(teacherId: "teacher_1")
        XCTAssertTrue(lessons.isEmpty)
    }
    
    func testAdjustLessonsBalanceIncrementsBalanceCorrectly() async throws {
        let student = User(
            id: "student_1",
            name: "Alex",
            surname: "Smith",
            email: "student@test.com",
            role: .student,
            lessonsBalance: 5
        )
        try await sut.saveUser(student)
        try await sut.adjustLessonsBalance(studentId: "student_1", delta: 3)
        let updatedUser = try await sut.fetchUser(id: "student_1")
        XCTAssertEqual(sut.adjustLessonsBalanceCalledWith?.userId, "student_1")
        XCTAssertEqual(sut.adjustLessonsBalanceCalledWith?.delta, 3)
        XCTAssertEqual(updatedUser.lessonsBalance, 8)
    }
    
    // MARK: - Homework Tests
    func testSaveHomeworkAndFetchHomeworksSuccess() async throws {
        let homework = Homework(
            id: "hw_1",
            studentId: "student_1",
            teacherId: "teacher_1",
            lessonId: "lesson_1",
            studentName: "John Doe",
            title: "Grammar Practice",
            description: "Complete exercises 1 to 5",
            sourceLink: "",
            status: .pending,
            grade: nil,
            teacherFeedback: nil,
            createdAt: Date(),
            reviewedAt: nil
        )
        try await sut.saveHomework(homework)
        let homeworks = try await sut.fetchHomeworks(teacherId: "teacher_1")
        XCTAssertEqual(homeworks.count, 1)
        XCTAssertEqual(homeworks.first?.title, "Grammar Practice")
    }
    
    // MARK: - Schedule Tests
    func testSaveScheduleAndFetchSchedulesSuccess() async throws {
        let schedule = Schedule(
            id: "sch_1",
            studentId: "student_1",
            teacherId: "teacher_1",
            weekday: 1,
            time: "15:00",
            isActive: true,
            createdAt: Date()
        )
        let savedSchedule = try await sut.saveSchedule(schedule)
        let activeSchedules = try await sut.fetchSchedules(teacherId: "teacher_1")
        XCTAssertEqual(savedSchedule.id, "sch_1")
        XCTAssertEqual(activeSchedules.count, 1)
        XCTAssertEqual(activeSchedules.first?.weekday, 1)
    }
    
    // MARK: - Error Handling Tests
    func testServiceWhenShouldReturnErrorThrowsCustomError() async {
        sut.shouldReturnError = true
        do {
            _ = try await sut.fetchUser(id: "any_id")
            XCTFail("Should have thrown error")
        } catch {
            XCTAssertEqual((error as NSError).domain, "FirestoreError")
        }
    }
}
