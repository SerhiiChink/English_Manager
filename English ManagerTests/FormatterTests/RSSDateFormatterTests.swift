//
//  RSSDateFormatterTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 16.09.2026.
//

import XCTest
@testable import English_Manager

final class RSSDateFormatterTests: XCTestCase {
    // MARK: - Properties
    private var sut: RSSDateFormatter!

    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        sut = RSSDateFormatter()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Tests
    func testDateFromRFC822StringParsesSuccessfully() {
        let dateString = "Wed, 13 Aug 2026 14:30:00 +0000"
        let result = sut.date(from: dateString)
        XCTAssertNotNil(result)
    }

    func testDateFromISO8601StringParsesSuccessfully() {
        let dateString = "2026-08-13T14:30:00+0000"
        let result = sut.date(from: dateString)
        XCTAssertNotNil(result)
    }

    func testDateFromISO8601WithMillisecondsStringParsesSuccessfully() {
        let dateString = "2026-08-13T14:30:00.123+0000"
        let result = sut.date(from: dateString)
        XCTAssertNotNil(result)
    }

    func testDateFromInvalidStringReturnsNil() {
        let invalidDateString = "13-08-2026 14:30"
        let result = sut.date(from: invalidDateString)
        XCTAssertNil(result)
    }

    func testDateFromEmptyStringReturnsNil() {
        let result = sut.date(from: "")
        XCTAssertNil(result)
    }
}
