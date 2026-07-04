//
//  HomeworkStatusMapper.swift
//  English Manager
//
//  Created by Sergej Klepikov on 22.05.2026.
//

import UIKit

enum HomeworkStatusMapper {
    static func style(for homework: Homework) -> HomeworkStatusStyle {
        switch homework.status {
        case .pending:
            return .init(text: "pending".localized,
                         badgeColor: .Brand.surfaceFill,
                         accentColor: .appGold,
                         icon: "clock.fill")
        case .reviewed, .seen:
            guard let grade = homework.grade else {
                return .init(text: "reviewed".localized,
                             badgeColor: .appGreen,
                             accentColor: .appGreen,
                             icon: "checkmark.circle.fill")
            }
            let gradeStyle = gradeStyle(for: grade)
            return .init (text: "\("grade".localized) \(grade)",
                          badgeColor: gradeStyle.color,
                          accentColor: .appGreen,
                          icon: gradeStyle.icon)
        }
    }
    
    // MARK: - Private
    private static func gradeStyle(for grade: Int) -> (color: UIColor,
                                                       icon: String) {
        switch grade {
        case 1...3:
            return (.appRed, "xmark.circle.fill")
        case 4...6:
            return (.appGold, "chart.bar.xaxis")
        default:
            return (.appGreen, "star.fill")
        }
    }
}
