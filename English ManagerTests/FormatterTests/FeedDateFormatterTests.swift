//
//  FeedDateFormatterTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 16.09.2026.
//

import XCTest
@testable import English_Manager

final class FeedDateFormatterTests: XCTestCase {
    // MARK: - Properties
    private var sut: FeedDateFormatter!

    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        sut = FeedDateFormatter()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Tests
    func testRelativeStringReturnsFormattedRelativeDate() {
        let now = Date()
        let pastDate = Calendar.current.date(byAdding: .hour,
                                             value: -2,
                                             to: now) ?? now
        let expectedFormatter = RelativeDateTimeFormatter()
        expectedFormatter.unitsStyle = .abbreviated
        let expectedString = expectedFormatter.localizedString(for: pastDate,
                                                               relativeTo: now)
        let result = sut.relativeString(from: pastDate)
        XCTAssertFalse(result.isEmpty)
        XCTAssertEqual(result, expectedString)
    }

    func testRelativeStringForCurrentDateReturnsNowString() {
        let now = Date()
        let expectedFormatter = RelativeDateTimeFormatter()
        expectedFormatter.unitsStyle = .abbreviated
        let expectedString = expectedFormatter.localizedString(for: now,
                                                               relativeTo: now)
        let result = sut.relativeString(from: now)
        XCTAssertEqual(result, expectedString)
    }
}
