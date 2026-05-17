//
//  AccountStatusMapper.swift
//  English Manager
//
//  Created by Sergej Klepikov on 08.05.2026.
//

import UIKit

struct AccountStatusStyle {
    let text: String
    let icon: String
    let color: UIColor
}

enum AccountStatusMapper {
    static func style(balance: Int,
                      hasPending: Bool,
                      minLessons: Int) -> AccountStatusStyle {
        if hasPending {
            return .init(text: "pending".localized,
                         icon: "clock.fill",
                         color: .appGold)
        }
        let level = BalanceLevelMapper.level(balance: balance,
                                             minLessons: minLessons)
        switch level {
            
        case .empty:
            return .init(text: "not_paid".localized,
                         icon: "xmark.circle.fill",
                         color: .appRed)
        case .low, .medium:
            return .init(text: "low_balance".localized,
                         icon: "exclamationmark.circle.fill",
                         color: .appOrange)
        case .ok:
            return .init(text: "paid".localized,
                         icon: "checkmark.circle.fill",
                         color: .appGreen)
        }
    }
}
