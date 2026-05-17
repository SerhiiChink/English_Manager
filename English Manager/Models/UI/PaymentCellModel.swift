//
//  PaymentCellModel.swift
//  English Manager
//
//  Created by Sergej Klepikov on 11.04.2026.
//

import Foundation

struct PaymentCellModel {
    let name: String
    let balanceLevel: BalanceLevel
    let hasPending: Bool
    let balanceText: String
    let photoURL: String?
}
