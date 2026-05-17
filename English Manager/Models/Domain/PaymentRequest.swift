//
//  PaymentRequest.swift
//  English Manager
//
//  Created by Sergej Klepikov on 05.03.2026.
//

import Foundation
import FirebaseFirestore

struct PaymentRequest: Codable {
    @DocumentID var id: String?
    let studentId: String
    let teacherId: String
    var studentName: String
    let lessonsCount: Int
    var confirmedLessons: Int?
    var amount: Double
    var status: PaymentStatus
    let createdAt: Date
    var confirmedAt: Date?
    var hiddenForTeacher: Bool?
    var hiddenForStudent: Bool?
}

enum PaymentStatus: String, Codable {
    case pending
    case confirmed
    case rejected
}
