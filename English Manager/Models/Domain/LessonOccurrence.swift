//
//  LessonOccurrence.swift
//  English Manager
//
//  Created by Sergej Klepikov on 10.04.2026.
//

import Foundation
import FirebaseFirestore

struct LessonOccurrence: Codable {
    @DocumentID var id: String?
    let studentId: String
    let teacherId: String
    var scheduleId: String?
    var scheduledAt: Date
    var status: OccurrenceStatus
    var cancelledBy: CancelledBy?
    var cancelledAt: Date?
    var notifiedAt: Date?
    var lessonId: String?
}

enum OccurrenceStatus: String, Codable {
    case scheduled
    case completed
    case charged
    case missed
    case rescheduled
    case cancelled
}

enum CancelledBy: String, Codable {
    case student
    case teacher
}

