//
//  MockLessonFormatter.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 16.09.2026.
//

import Foundation
@testable import English_Manager

final class MockLessonFormatter: LessonFormatterProtocol {
    // MARK: - Stubbed Properties
    var stubbedScheduledText = "Scheduled · 01.01.25"
    var stubbedLessonDateString = "01 Jan 2025"
    var stubbedDetailDateString = "January 1, 2025"
    var stubbedOccurrenceDateString = "01.01.2025"

    // MARK: - LessonFormatterProtocol
    func scheduledText(for lesson: Lesson) -> String {
        return stubbedScheduledText
    }

    func lessonDateString(for lesson: Lesson) -> String {
        return stubbedLessonDateString
    }

    func detailDateString(for lesson: Lesson) -> String {
        return stubbedDetailDateString
    }

    func occurrenceDateString(for date: Date) -> String {
        return stubbedOccurrenceDateString
    }
}
