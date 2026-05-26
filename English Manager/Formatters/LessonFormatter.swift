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
    func lessonDateString(for lesson: Lesson) -> String {
        SharedDateFormatter.short.string(from: lesson.date)
    }
    
    func detailDateString(for lesson: Lesson) -> String {
        SharedDateFormatter.long.string(from: lesson.date)
    }
    
    func scheduledText(for lesson: Lesson) -> String {
        "\("scheduled".localized) · \(SharedDateFormatter.short.string(from: lesson.date))"
    }
}
