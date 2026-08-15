//
//  PushNotificationMapper.swift
//  English Manager
//
//  Created by Sergej Klepikov on 28.05.2026.
//

import Foundation

enum PushType: String {
    case paymentPending = "payment_pending"
    case balanceEmpty = "balance_empty"
    case lessonReminder = "lesson_reminder"
    case lessonCompleted = "lesson_completed"
    case lessonRescheduled = "lesson_rescheduled"
    case unknown
    
    init(rawValue: String) {
        switch rawValue {
        case "payment_pending": self = .paymentPending
        case "balance_empty": self = .balanceEmpty
        case "lesson_reminder": self = .lessonReminder
        case "lesson_completed": self = .lessonCompleted
        case "lesson_rescheduled": self = .lessonRescheduled
        default: self = .unknown
        }
    }
}
    
enum PushNavigationTarget {
    case payments
    case lessons
    case none
}

enum PushNotificationMapper {
    static func navigationTarget(for type: PushType) -> PushNavigationTarget {
        switch type {
        case .paymentPending, .balanceEmpty:
            return .payments
        case .lessonReminder, .lessonCompleted, .lessonRescheduled:
            return .lessons
        case .unknown:
            return .none
        }
    }
    
    static func navigationTarget(from userInfo: [AnyHashable: Any]) -> PushNavigationTarget {
        let rawType = userInfo["type"] as? String ?? ""
        return navigationTarget(for: PushType(rawValue: rawType))
    }
}

