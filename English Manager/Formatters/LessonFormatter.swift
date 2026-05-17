//
//  LessonFormatter.swift
//  English Manager
//
//  Created by Sergej Klepikov on 14.03.2026.
//

import Foundation

protocol LessonFormatterProtocol {
    func lessonDateString(for lesson: Lesson) -> String
    func detailDateString(for lesson: Lesson) -> String
    func scheduledText(for lesson: Lesson) -> String
}

final class LessonFormatter: LessonFormatterProtocol {
    private static let shortFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    private static let longFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()
    
    func lessonDateString(for lesson: Lesson) -> String {
        LessonFormatter.shortFormatter.string(from: lesson.date)
    }
    
    func detailDateString(for lesson: Lesson) -> String {
        LessonFormatter.longFormatter.string(from: lesson.date)
    }
    
    func scheduledText(for lesson: Lesson) -> String {
        "\("scheduled".localized) · \(LessonFormatter.shortFormatter.string(from: lesson.date))"
    }
}
