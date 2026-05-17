//
//  OccurrenceStatusMapper.swift
//  English Manager
//
//  Created by Sergej Klepikov on 22.04.2026.
//

import UIKit

struct OccurrenceStatusStyle {
    let text: String
    let color: UIColor
}

enum OccurrenceStatusMapper {
    static func style(for status: OccurrenceStatus) -> OccurrenceStatusStyle {
        switch status {
        case .scheduled:
            return .init(text: "scheduled".localized, color: .appGold)
        case .completed:
            return .init(text: "completed".localized, color: .appGreen)
        case .cancelled:
            return .init(text: "cancelled".localized, color: .appRed)
        }
    }
    
    static func style(for lesson: Lesson,
                      formatter: LessonFormatterProtocol) -> OccurrenceStatusStyle {
        lesson.date > Date()
        ? .init(text: formatter.scheduledText(for: lesson), color: .appGold)
        : .init(text: "completed".localized, color: .appGreen)
    }
}
