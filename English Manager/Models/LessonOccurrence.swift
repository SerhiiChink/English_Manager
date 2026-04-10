//
//  LessonOccurrence.swift
//  English Manager
//
//  Created by Sergej Klepikov on 10.04.2026.
//

import Foundation

struct LessonOccurrence: Codable {
    var id: String?
    let studentId: String
    let teacherId: String
    let scheduleId: String
    let scheduleAt: Date
    var status: OccurrenceStatus
    var cancelledBy: CancelledBy?
    var cancelledAt: Date?
    var notifiedAt: Date?
    var lessonId: String?
}

enum OccurrenceStatus: String, Codable {
    case scheduled
    case completed
    case cancelled
}

enum CancelledBy: String, Codable {
    case student
    case teacher
}

