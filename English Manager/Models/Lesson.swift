//
//  Lesson.swift
//  English Manager
//
//  Created by Sergej Klepikov on 05.03.2026.
//

import Foundation

struct Lesson: Codable {
    var id: String?
    let studentId: String
    let teacherId: String
    let studentName: String
    let date: Date
    let topic: String
    let bookTitle: String
    let pages: String
    let attended: Bool
    var vocabulary: [String]
}
