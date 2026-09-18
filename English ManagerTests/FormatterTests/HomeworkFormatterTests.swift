//
//  HomeworkFormatterTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 16.09.2026.
//

import XCTest
@testable import English_Manager

final class HomeworkFormatterTests: XCTestCase {
    // MARK: - Properties
    private var sut: HomeworkFormatter!

    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        sut = HomeworkFormatter()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Helpers
    private func makeHomework(
        title: String = "Grammar Test",
        description: String = "Do ex 1-5",
        studentName: String = "Anna Smith",
        status: HomeworkStatus = .pending,
        feedback: String? = nil,
        createdAt: Date = Date()
    ) -> Homework {
        Homework(
            id: "hw_123",
            studentId: "student_123",
            teacherId: "teacher_123",
            lessonId: "lesson_123",
            studentName: studentName,
            title: title,
            description: description,
            sourceLink: "https://example.com",
            status: status,
            grade: nil,
            teacherFeedback: feedback,
            createdAt: createdAt,
            reviewedAt: nil
        )
    }

    private func makeDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.timeZone = TimeZone.current
        return Calendar.current.date(from: components) ?? Date()
    }

    // MARK: - Date Formatting Tests
    func testShortDateStringFormatsShortDate() {
        let date = makeDate(year: 2026, month: 3, day: 30)
        let homework = makeHomework(createdAt: date)
        let expected = SharedDateFormatter.short.string(from: date)
        XCTAssertEqual(sut.shortDateString(homework), expected)
    }

    func testLongDateStringFormatsLongDate() {
        let date = makeDate(year: 2026, month: 3, day: 30)
        let homework = makeHomework(createdAt: date)
        let expected = SharedDateFormatter.long.string(from: date)
        XCTAssertEqual(sut.longDateString(homework), expected)
    }

    // MARK: - CellModel Tests
    func testCellModelWhenShowStudentIsTrueIncludesStudentName() {
        let homework = makeHomework(studentName: "Anna Smith")
        let model = sut.cellModel(for: homework, showStudent: true)
        XCTAssertEqual(model.studentName, "Anna Smith")
    }

    func testCellModelWhenShowStudentIsFalseNilStudentName() {
        let homework = makeHomework(studentName: "Anna Smith")
        let model = sut.cellModel(for: homework, showStudent: false)
        XCTAssertNil(model.studentName)
    }

    func testCellModelWhenDescriptionIsEmptyNilDescription() {
        let homework = makeHomework(description: "")
        let model = sut.cellModel(for: homework, showStudent: true)
        XCTAssertNil(model.description)
    }

    func testCellModelWhenStatusIsPendingNilFeedbackText() {
        let homework = makeHomework(status: .pending, feedback: "Great work!")
        let model = sut.cellModel(for: homework, showStudent: true)
        XCTAssertNil(model.feedbackText)
    }

    func testCellModelWhenStatusIsReviewedAndFeedbackExistsReturnsFeedbackText() {
        let homework = makeHomework(status: .reviewed, feedback: "Great work!")
        let model = sut.cellModel(for: homework, showStudent: true)
        XCTAssertEqual(model.feedbackText, "Great work!")
    }

    func testCellModelWhenStatusIsReviewedAndFeedbackIsEmptyNilFeedbackText() {
        let homework = makeHomework(status: .reviewed, feedback: "")
        let model = sut.cellModel(for: homework, showStudent: true)
        XCTAssertNil(model.feedbackText)
    }
}
