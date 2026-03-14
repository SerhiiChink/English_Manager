//
//  Vocabulary.swift
//  English Manager
//
//  Created by Sergej Klepikov on 05.03.2026.
//

import Foundation

struct Vocabulary: Codable {
    var id: String?
    let lessonId: String
    let studentId: String
    let word: String
    let translation: String
    let createdAt: Date
}
