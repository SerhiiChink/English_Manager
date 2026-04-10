//
//  Constants.swift
//  English Manager
//
//  Created by Sergej Klepikov on 05.03.2026.
//

import Foundation

    // MARK: - Firebase Collections
enum Collections {
    static let users = "users"
    static let lessons = "lessons"
    static let homeworks = "homeworks"
    static let payments = "payments"
    static let vocabulary = "vocabulary"
    static let schedules = "schedules"
    static let teacherSettings = "teacherSettings"
    static let lessonOccurrences = "lessonOccurrences"
}
    
    // MARK: - Layout
enum Layout {
    static let padding: CGFloat = 20
    static let cardPadding: CGFloat = 14
    static let cornerRadius: CGFloat = 16
    static let buttonHeight: CGFloat = 56
    static let tabBarHeight: CGFloat = 70
}

    // MARK: - UserDefaults
enum UDKeys {
    static let userRole = "userRole"
    static let userId = "userId"
}
