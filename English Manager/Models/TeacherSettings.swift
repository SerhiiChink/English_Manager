//
//  TeacherSettings.swift
//  English Manager
//
//  Created by Sergej Klepikov on 04.04.2026.
//

import Foundation

struct TeacherSettings: Codable {
    let teacherId: String
    var lessonPrice: Double
    var minLessons: Int
    var currency: String
    
//    let defaultMinLessons: Int?
//    let defaultCurrency: String?
}
