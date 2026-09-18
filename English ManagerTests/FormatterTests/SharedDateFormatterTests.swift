//
//  SharedDateFormatterTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 16.09.2026.
//

import XCTest
@testable import English_Manager

final class SharedDateFormatterTests: XCTestCase {
    // MARK: - Helpers
    private func makeDate(year: Int,
                          month: Int,
                          day: Int,
                          hour: Int = 0,
                          minute: Int = 0) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.timeZone = TimeZone.current
        return Calendar.current.date(from: components) ?? Date()
    }

    // MARK: - Tests
    func testShortDateFormatterFormatsCorrectPattern() {
        let date = makeDate(year: 2026, month: 5, day: 22)
        XCTAssertEqual(SharedDateFormatter.short.dateFormat, "dd.MM.yy")
        XCTAssertEqual(SharedDateFormatter.short.string(from: date),
                       "22.05.26")
    }

    func testLongDateFormatterFormatsCorrectPattern() {
        let date = makeDate(year: 2026, month: 5, day: 22)
        XCTAssertEqual(SharedDateFormatter.long.dateFormat, "dd MMM yyyy")
        let expectedFormatter = DateFormatter()
        expectedFormatter.dateFormat = "dd MMM yyyy"
        let expectedString = expectedFormatter.string(from: date)
        XCTAssertEqual(SharedDateFormatter.long.string(from: date),
                       expectedString)
    }

    func testLongWithTimeDateFormatterFormatsCorrectPattern() {
        let date = makeDate(year: 2026,
                            month: 5,
                            day: 22,
                            hour: 14,
                            minute: 30)
        XCTAssertEqual(SharedDateFormatter.longWithTime.dateFormat,
                       "dd MMM yyyy, HH:mm")
        let expectedFormatter = DateFormatter()
        expectedFormatter.dateFormat = "dd MMM yyyy, HH:mm"
        let expectedString = expectedFormatter.string(from: date)
        XCTAssertEqual(SharedDateFormatter.longWithTime.string(from: date),
                       expectedString)
    }
}
