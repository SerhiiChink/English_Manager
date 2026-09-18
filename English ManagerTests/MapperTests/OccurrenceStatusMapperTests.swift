//
//  OccurrenceStatusMapperTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 15.09.2026.
//

import XCTest
import UIKit
@testable import English_Manager

final class OccurrenceStatusMapperTests: XCTestCase {
    // MARK: - Properties
    private var formatter: MockLessonFormatter!

    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        formatter = MockLessonFormatter()
    }

    override func tearDown() {
        formatter = nil
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
            bookTitle: "",
            pages: "",
            attended: true,
            vocabulary: [],
            sourceLinks: []
        )
    }

    // MARK: - Style Tests
    func testStyleWhenLessonInFutureReturnsScheduledTextAndGoldColor() {
        let futureDate = Date().addingTimeInterval(3600)
        let lesson = makeLesson(date: futureDate)
        formatter.stubbedScheduledText = "Scheduled · 01.01.25"
        let style = OccurrenceStatusMapper.style(for: lesson,
                                                 formatter: formatter)
        XCTAssertEqual(style.text, "Scheduled · 01.01.25")
        XCTAssertEqual(style.color, .appGold)
    }

    func testStyleWhenLessonInPastReturnsCompletedTextAndGreenColor() {
        let pastDate = Date().addingTimeInterval(-3600)
        let lesson = makeLesson(date: pastDate)
        let style = OccurrenceStatusMapper.style(for: lesson,
                                                 formatter: formatter)
        XCTAssertEqual(style.text, "completed".localized)
        XCTAssertEqual(style.color, .appGreen)
    }

    // MARK: - Accent Color Tests
    func testAccentColorWhenLessonInFutureReturnsGoldColor() {
        let futureDate = Date().addingTimeInterval(3600)
        let lesson = makeLesson(date: futureDate)
        let color = OccurrenceStatusMapper.accentColor(for: lesson)
        XCTAssertEqual(color, .appGold)
    }

    func testAccentColorWhenLessonInPastReturnsGreenColor() {
        let pastDate = Date().addingTimeInterval(-3600)
        let lesson = makeLesson(date: pastDate)
        let color = OccurrenceStatusMapper.accentColor(for: lesson)
        XCTAssertEqual(color, .appGreen)
    }
}
