//
//  AccountStatusMapperTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 16.09.2026.
//

import XCTest
import UIKit
@testable import English_Manager

final class AccountStatusMapperTests: XCTestCase {
    // MARK: - Pending Status Tests
    func testStyleWhenHasPendingIsTrueReturnsPendingStyle() {
        let style = AccountStatusMapper.style(balance: 5,
                                              hasPending: true,
                                              minLessons: 4)
        XCTAssertEqual(style.text, "pending".localized)
        XCTAssertEqual(style.icon, "clock.fill")
        XCTAssertEqual(style.color, .appGold)
    }

    // MARK: - Balance Level Style Tests
    func testStyleWhenBalanceIsEmptyReturnsNotPaidStyle() {
        let style = AccountStatusMapper.style(balance: 0,
                                              hasPending: false,
                                              minLessons: 4)
        XCTAssertEqual(style.text, "not_paid".localized)
        XCTAssertEqual(style.icon, "xmark.circle.fill")
        XCTAssertEqual(style.color, .appRed)
    }

    func testStyleWhenBalanceIsLowOrMediumReturnsLowBalanceStyle() {
        let lowStyle = AccountStatusMapper.style(balance: 1,
                                                 hasPending: false,
                                                 minLessons: 4)
        XCTAssertEqual(lowStyle.text, "low_balance".localized)
        XCTAssertEqual(lowStyle.icon, "exclamationmark.circle.fill")
        XCTAssertEqual(lowStyle.color, .appOrange)
        let mediumStyle = AccountStatusMapper.style(balance: 2,
                                                    hasPending: false,
                                                    minLessons: 4)
        XCTAssertEqual(mediumStyle.text, "low_balance".localized)
        XCTAssertEqual(mediumStyle.icon, "exclamationmark.circle.fill")
        XCTAssertEqual(mediumStyle.color, .appOrange)
    }

    func testStyleWhenBalanceIsOkReturnsPaidStyle() {
        let style = AccountStatusMapper.style(balance: 4,
                                              hasPending: false,
                                              minLessons: 4)
        XCTAssertEqual(style.text, "paid".localized)
        XCTAssertEqual(style.icon, "checkmark.circle.fill")
        XCTAssertEqual(style.color, .appGreen)
    }
}
