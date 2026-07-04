//
//  Homework.swift
//  English Manager
//
//  Created by Sergej Klepikov on 05.03.2026.
//

import Foundation
import FirebaseFirestore

struct Homework: Codable {
    @DocumentID var id: String?
    let studentId: String
    let teacherId: String
    let lessonId: String?
    var studentName: String
    var title: String
    var description: String
    var sourceLink: String
    var status: HomeworkStatus
    var grade: Int?
    var teacherFeedback: String?
    let createdAt: Date
    var reviewedAt: Date?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Homework, rhs: Homework) -> Bool {
        lhs.id == rhs.id
    }
}

enum HomeworkStatus: String, Codable {
    case pending
    case reviewed
    case seen
}
