//
//  Lesson.swift
//  English Manager
//
//  Created by Sergej Klepikov on 05.03.2026.
//

import Foundation
import FirebaseFirestore

struct SourceLink: Codable, Hashable {
    let url: String
    let title: String
}

struct Lesson: Codable {
    @DocumentID var id: String?
    let studentId: String
    let teacherId: String
    var occurrenceId: String?
    var studentName: String
    var date: Date
    var topic: String
    var bookTitle: String
    var pages: String
    var attended: Bool
    var vocabulary: [String]
    var sourceLinks: [SourceLink]
}
