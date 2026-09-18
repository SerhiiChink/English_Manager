//
//  PaymentStatusMapperTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 16.09.2026.
//

import XCTest
import UIKit
@testable import English_Manager

@MainActor
final class PaymentStatusMapperTests: XCTestCase {
    // MARK: - Style Tests
    func testStyleForPendingStatusReturnsPendingTextClockIconAndGoldColor() {
        let style = PaymentStatusMapper.style(for: .pending)
        XCTAssertEqual(style.text, "pending".localized)
        XCTAssertEqual(style.icon, "clock.fill")
        XCTAssertEqual(style.color, .appGold)
    }

    func testStyleForConfirmedStatusReturnsConfirmedTextCheckmarkIconAndGreenColor() {
        let style = PaymentStatusMapper.style(for: .confirmed)
        XCTAssertEqual(style.text, "confirmed".localized)
        XCTAssertEqual(style.icon, "checkmark.circle.fill")
        XCTAssertEqual(style.color, .appGreen)
    }

    func testStyleForRejectedStatusReturnsRejectedTextXmarkIconAndRedColor() {
        let style = PaymentStatusMapper.style(for: .rejected)
        XCTAssertEqual(style.text, "rejected".localized)
        XCTAssertEqual(style.icon, "xmark.circle.fill")
        XCTAssertEqual(style.color, .appRed)
    }
}
