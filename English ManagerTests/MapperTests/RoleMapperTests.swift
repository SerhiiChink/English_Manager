//
//  RoleMapperTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 16.09.2026.
//

import XCTest
import UIKit
@testable import English_Manager

final class RoleMapperTests: XCTestCase {
    // MARK: - Style Tests
    func testStyleForTeacherRoleReturnsTeacherStyle() {
        let style = RoleMapper.style(for: .teacher)
        XCTAssertEqual(style.icon, "graduationcap.fill")
        XCTAssertEqual(style.cardIcon, "books.vertical")
        XCTAssertEqual(style.name, "teacher".localized)
        XCTAssertEqual(style.description, "teacher_role_description".localized)
    }

    func testStyleForStudentRoleReturnsStudentStyle() {
        let style = RoleMapper.style(for: .student)
        XCTAssertEqual(style.icon, "graduationcap")
        XCTAssertEqual(style.cardIcon, "pencil")
        XCTAssertEqual(style.name, "student".localized)
        XCTAssertEqual(style.description, "student_role_description".localized)
    }
}
