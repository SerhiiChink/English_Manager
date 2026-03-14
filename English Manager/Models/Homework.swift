//
//  Homework.swift
//  English Manager
//
//  Created by Sergej Klepikov on 05.03.2026.
//

import Foundation

struct Homework: Codable {
    var id: String?
    let studentId: String
    let teacherId: String
    let lessonId: String
    var photoURL: String
    var status: HomeworkStatus
    var teacherComment: String
    var grade: String
    let uploadedAt: Date
    var reviewedAt: Date?
}

enum HomeworkStatus: String, Codable {
    case pending
    case reviewed
    case seen
}
