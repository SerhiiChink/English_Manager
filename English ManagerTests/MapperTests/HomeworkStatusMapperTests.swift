//
//  HomeworkStatusMapperTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 16.09.2026.
//

import XCTest
import UIKit
@testable import English_Manager

final class HomeworkStatusMapperTests: XCTestCase {
    // MARK: - Helpers
    private func makeHomework(status: HomeworkStatus,
                              grade: Int? = nil) -> Homework {
        Homework(
            id: "hw_123",
            studentId: "student_123",
            teacherId: "teacher_123",
            lessonId: "lesson_123",
            studentName: "Anna Smith",
            title: "Grammar Practice",
            description: "Complete exercises",
            sourceLink: "https://example.com",
            status: status,
            grade: grade,
            teacherFeedback: nil,
            createdAt: Date(),
            reviewedAt: nil
        )
    }

    // MARK: - Pending Status Tests
    func testStyleForPendingStatusReturnsPendingStyle() {
        let homework = makeHomework(status: .pending)
        let style = HomeworkStatusMapper.style(for: homework)
        XCTAssertEqual(style.text, "pending".localized)
        XCTAssertEqual(style.badgeColor, .Brand.surfaceFill)
        XCTAssertEqual(style.accentColor, .appGold)
        XCTAssertEqual(style.icon, "clock.fill")
    }

    // MARK: - Reviewed / Seen Without Grade Tests
    func testStyleForReviewedStatusWithoutGradeReturnsReviewedStyle() {
        let homework = makeHomework(status: .reviewed, grade: nil)
        let style = HomeworkStatusMapper.style(for: homework)
        XCTAssertEqual(style.text, "reviewed".localized)
        XCTAssertEqual(style.badgeColor, .appGreen)
        XCTAssertEqual(style.accentColor, .appGreen)
        XCTAssertEqual(style.icon, "checkmark.circle.fill")
    }

    // MARK: - Reviewed / Seen With Grade Tests
    func testStyleWhenGradeIsLowReturnsRedBadgeAndXmarkIcon() {
        let homework = makeHomework(status: .reviewed, grade: 2)
        let style = HomeworkStatusMapper.style(for: homework)
        XCTAssertEqual(style.text, "\("grade".localized) 2")
        XCTAssertEqual(style.badgeColor, .appRed)
        XCTAssertEqual(style.accentColor, .appGreen)
        XCTAssertEqual(style.icon, "xmark.circle.fill")
    }

    func testStyleWhenGradeIsMediumReturnsGoldBadgeAndBarIcon() {
        let homework = makeHomework(status: .reviewed, grade: 5)
        let style = HomeworkStatusMapper.style(for: homework)
        XCTAssertEqual(style.text, "\("grade".localized) 5")
        XCTAssertEqual(style.badgeColor, .appGold)
        XCTAssertEqual(style.accentColor, .appGreen)
        XCTAssertEqual(style.icon, "chart.bar.xaxis")
    }

    func testStyleWhenGradeIsHighReturnsGreenBadgeAndStarIcon() {
        let homework = makeHomework(status: .seen, grade: 9)
        let style = HomeworkStatusMapper.style(for: homework)
        XCTAssertEqual(style.text, "\("grade".localized) 9")
        XCTAssertEqual(style.badgeColor, .appGreen)
        XCTAssertEqual(style.accentColor, .appGreen)
        XCTAssertEqual(style.icon, "star.fill")
    }
}
