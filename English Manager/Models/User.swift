//
//  User.swift
//  English Manager
//
//  Created by Sergej Klepikov on 05.03.2026.
//

import Foundation

struct User: Codable {
    let id: String
    let name: String
    let email: String
    var role: UserRole?
    var fcmToken: String?
    var lessonsBalance: Int?
    var teacherId: String?
}

enum UserRole: String, Codable {
    case teacher
    case student
}
