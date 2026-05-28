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
    case unknown
    
    init(rawValue: String) {
        switch rawValue {
        case "payment_pending": self = .paymentPending
        case "balance_empty": self = .balanceEmpty
        case "lesson_reminder": self = .lessonReminder
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
        case .lessonReminder:
            return .lessons
        case .unknown:
            return .none
        }
    }
}

