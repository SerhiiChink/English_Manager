//
//  BalanceLevelMapper.swift
//  English Manager
//
//  Created by Sergej Klepikov on 30.04.2026.
//

import UIKit

enum BalanceLevel {
    case empty
    case low
    case medium
    case ok
}

struct BalanceStyle {
    let color: UIColor
}

enum BalanceLevelMapper {
    static func style(for level: BalanceLevel) -> BalanceStyle {
        switch level {
        case .empty:
            return .init(color: .appRed)
        case .low:
            return .init(color: .appOrange)
        case .medium:
            return .init(color: .appGold)
        case .ok:
            return .init(color: .appGreen)
        }
    }
    
    static func level(balance: Int, minLessons: Int) -> BalanceLevel {
        guard minLessons > 0 else { return balance == 0 ? .empty : .ok }
        switch balance {
        case 0:
            return .empty
        case 1 ..< max(1, minLessons / 2):
            return .low
        case max(1, minLessons / 2) ..< minLessons:
            return .medium
        default:
            return.ok
        }
    }
}
