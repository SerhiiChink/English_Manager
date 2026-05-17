//
//  User.swift
//  English Manager
//
//  Created by Sergej Klepikov on 05.03.2026.
//

import Foundation

struct User: Codable {
    let id: String
    var name: String
    var surname: String?
    let email: String
    var role: UserRole?
    var photoURL: String?
    var teacherAlias: String?
    var fcmToken: String?
    var lessonsBalance: Int?
    var totalLessonsPaid: Int?
    var teacherId: String?
    var isAutoDebitEnabled: Bool?
    
    var fullName: String {
        [name, surname]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
    
    var displayName: String {
        fullName.isEmpty ? email : fullName
    }
    
    var shortName: String {
        name.isEmpty ? email : name
    }
}

enum UserRole: String, Codable {
    case teacher
    case student
}
