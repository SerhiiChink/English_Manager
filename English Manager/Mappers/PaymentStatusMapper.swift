//
//  PaymentStatusMapper.swift
//  English Manager
//
//  Created by Sergej Klepikov on 05.05.2026.
//

import UIKit

struct PaymentStatusStyle {
    let text: String
    let icon: String
    let color: UIColor
}

enum PaymentStatusMapper {
    static func style(for status: PaymentStatus) -> PaymentStatusStyle {
        switch status {
        case .pending:
            return .init(text: "pending".localized,
                         icon: "clock.fill",
                         color: .appGold)
        case .confirmed:
            return .init(text: "confirmed".localized,
                         icon: "checkmark.circle.fill",
                         color: .appGreen)
        case .rejected:
            return .init(text: "rejected".localized,
                         icon: "xmark.circle.fill",
                         color: .appRed)
        }
    }
}
