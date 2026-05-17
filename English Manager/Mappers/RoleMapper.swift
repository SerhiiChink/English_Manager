//
//  RoleMapper.swift
//  English Manager
//
//  Created by Sergej Klepikov on 11.05.2026.
//

import UIKit

struct RoleStyle {
    let icon: String
    let cardIcon: String
    let name: String
    let description: String
}

enum RoleMapper {
    static func style(for role: UserRole) -> RoleStyle {
        switch role {
        case .teacher:
            return .init(icon: "graduationcap.fill",
                         cardIcon: "books.vertical",
                         name: "teacher".localized,
                         description: "teacher_role_description".localized)
        case .student:
            return .init(icon: "graduationcap",
                         cardIcon: "pencil",
                         name: "student".localized,
                         description: "student_role_description".localized)
        }
    }
}
