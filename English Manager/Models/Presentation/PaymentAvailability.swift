//
//  PaymentAvailability.swift
//  English Manager
//
//  Created by Sergej Klepikov on 30.04.2026.
//

import Foundation

enum PaymentAvailability {
    case unavailable
    case priceOnly(price: Double)
    case full(price: Double, minLessons: Int)
}
