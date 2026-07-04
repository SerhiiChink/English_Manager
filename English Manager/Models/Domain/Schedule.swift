//
//  Schedule.swift
//  English Manager
//
//  Created by Sergej Klepikov on 04.04.2026.
//

import Foundation
import FirebaseFirestore

struct Schedule: Codable {
    @DocumentID var id: String?
    let studentId: String
    let teacherId: String
    var weekday: Int
    var time: String
    var isActive: Bool
    let createdAt: Date
}
