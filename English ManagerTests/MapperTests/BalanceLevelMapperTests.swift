//
//  BalanceLevelMapperTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 16.09.2026.
//

import XCTest
import UIKit
@testable import English_Manager

@MainActor
final class BalanceLevelMapperTests: XCTestCase {
    // MARK: - Style Tests
    func testStyleForEmptyLevelReturnsRedColor() {
        let style = BalanceLevelMapper.style(for: .empty)
        XCTAssertEqual(style.color, .appRed)
    }

    func testStyleForLowLevelReturnsOrangeColor() {
        let style = BalanceLevelMapper.style(for: .low)
        XCTAssertEqual(style.color, .appOrange)
    }

    func testStyleForMediumLevelReturnsGoldColor() {
        let style = BalanceLevelMapper.style(for: .medium)
        XCTAssertEqual(style.color, .appGold)
    }

    func testStyleForOkLevelReturnsGreenColor() {
        let style = BalanceLevelMapper.style(for: .ok)
        XCTAssertEqual(style.color, .appGreen)
    }

    // MARK: - Level Tests
    func testLevelWhenBalanceZeroOrNegativeReturnsEmpty() {
        XCTAssertEqual(BalanceLevelMapper.level(balance: 0,
                                                minLessons: 4), .empty)
        XCTAssertEqual(BalanceLevelMapper.level(balance: -2,
                                                minLessons: 4), .empty)
    }

    func testLevelWhenMinLessonsZeroOrNegativeReturnsOk() {
        XCTAssertEqual(BalanceLevelMapper.level(balance: 3,
                                                minLessons: 0), .ok)
        XCTAssertEqual(BalanceLevelMapper.level(balance: 3,
                                                minLessons: -1), .ok)
    }

    func testLevelWhenBalanceIsLowReturnsLow() {
        XCTAssertEqual(BalanceLevelMapper.level(balance: 1,
                                                minLessons: 4), .low)
    }

    func testLevelWhenBalanceIsMediumReturnsMedium() {
        XCTAssertEqual(BalanceLevelMapper.level(balance: 2,
                                                minLessons: 4), .medium)
        XCTAssertEqual(BalanceLevelMapper.level(balance: 3,
                                                minLessons: 4), .medium)
    }

    func testLevelWhenBalanceGreaterOrEqualToMinLessonsReturnsOk() {
        XCTAssertEqual(BalanceLevelMapper.level(balance: 4,
                                                minLessons: 4), .ok)
        XCTAssertEqual(BalanceLevelMapper.level(balance: 10,
                                                minLessons: 4), .ok)
    }
}
