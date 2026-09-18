//
//  LessonFormatterTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 16.09.2026.
//

import XCTest
@testable import English_Manager

final class LessonFormatterTests: XCTestCase {
    // MARK: - Properties
    private var sut: LessonFormatter!

    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        sut = LessonFormatter()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Helpers
    private func makeLesson(date: Date) -> Lesson {
        Lesson(
            studentId: "student_123",
            teacherId: "teacher_123",
            studentName: "Test Student",
            date: date,
            topic: "Grammar",
            bookTitle: "English Grammar",
            pages: "10-15",
            attended: true,
            vocabulary: [],
            sourceLinks: []
        )
    }

    private func makeDate(year: Int,
                          month: Int,
                          day: Int,
                          hour: Int = 12,
                          minute: Int = 0) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.timeZone = TimeZone.current
        return Calendar.current.date(from: components) ?? Date()
    }

    // MARK: - Tests
    func testLessonDateStringFormatsShortDate() {
        let date = makeDate(year: 2026, month: 3, day: 14)
        let lesson = makeLesson(date: date)
        let expected = SharedDateFormatter.short.string(from: date)
        XCTAssertEqual(sut.lessonDateString(for: lesson), expected)
    }

    func testDetailDateStringFormatsLongDate() {
        let date = makeDate(year: 2026, month: 3, day: 14)
        let lesson = makeLesson(date: date)
        let expected = SharedDateFormatter.long.string(from: date)
        XCTAssertEqual(sut.detailDateString(for: lesson), expected)
    }

    func testScheduledTextFormatsScheduledPrefixAndShortDate() {
        let date = makeDate(year: 2026, month: 3, day: 14)
        let lesson = makeLesson(date: date)
        let dateString = SharedDateFormatter.short.string(from: date)
        let expected = "\("scheduled".localized) · \(dateString)"
        XCTAssertEqual(sut.scheduledText(for: lesson), expected)
    }

    func testOccurrenceDateStringFormatsLongDateWithTime() {
        let date = makeDate(year: 2026,
                            month: 3,
                            day: 14,
                            hour: 15,
                            minute: 30)
        let expected = SharedDateFormatter.longWithTime.string(from: date)
        XCTAssertEqual(sut.occurrenceDateString(for: date), expected)
    }
}
