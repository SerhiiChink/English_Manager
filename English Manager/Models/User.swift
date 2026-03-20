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
    var fcmToken: String?
    var lessonsBalance: Int?
    var teacherId: String?
    
    var fullName: String {
        [name, surname]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}

enum UserRole: String, Codable {
    case teacher
    case student
}
