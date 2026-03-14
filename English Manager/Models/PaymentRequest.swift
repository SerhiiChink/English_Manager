//
//  PaymentRequest.swift
//  English Manager
//
//  Created by Sergej Klepikov on 05.03.2026.
//

import Foundation

struct PaymentRequest: Codable {
    var id: String?
    let studentId: String
    let teacherId: String
    let studentName: String
    let lessonsCount: Int
    var confirmedLessons: Int?
    let amount: Double
    var status: PaymentStatus
    let createdAt: Date
    var confirmedAt: Date?
}

enum PaymentStatus: String, Codable {
    case pending
    case confirmed
    case rejected
}
