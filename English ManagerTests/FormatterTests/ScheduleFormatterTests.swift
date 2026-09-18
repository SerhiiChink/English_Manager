//
//  ScheduleFormatterTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 16.09.2026.
//

import XCTest
@testable import English_Manager

final class ScheduleFormatterTests: XCTestCase {
    // MARK: - Properties
    private var sut: ScheduleFormatter!

    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        sut = ScheduleFormatter()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Helpers
    private func makeDate(hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        components.timeZone = TimeZone.current
        return Calendar.current.date(from: components) ?? Date()
    }

    private func makeSchedule(weekday: Int, time: String = "15:00") -> Schedule {
        Schedule(
            id: "sched_123",
            studentId: "student_123",
            teacherId: "teacher_123",
            weekday: weekday,
            time: time,
            isActive: true,
            createdAt: Date()
        )
    }

    // MARK: - Time String Tests
    func testTimeStringFormatsDateToHHmm() {
        let date = makeDate(hour: 14, minute: 30)
        XCTAssertEqual(sut.timeString(from: date), "14:30")
    }

    // MARK: - Formatted Schedule Tests
    func testFormattedWithValidWeekdayReturnsWeekdaySymbolAndTime() {
        let schedule = makeSchedule(weekday: 2, time: "18:00")
        let weekdaySymbol = Calendar.current.weekdaySymbols[1]
        let expected = "\(weekdaySymbol) 18:00"
        XCTAssertEqual(sut.formatted(schedule, timezone: nil), expected)
    }

    func testFormattedWithInvalidWeekdayReturnsOnlyTime() {
        let schedule = makeSchedule(weekday: 0, time: "10:00")
        XCTAssertEqual(sut.formatted(schedule, timezone: nil), "10:00")
        let invalidSchedule = makeSchedule(weekday: 8, time: "10:00")
        XCTAssertEqual(sut.formatted(invalidSchedule, timezone: nil), "10:00")
    }

    func testFormattedWithTimezoneIdentifierAppendsCitySuffix() {
        let schedule = makeSchedule(weekday: 1, time: "12:00")
        let weekdaySymbol = Calendar.current.weekdaySymbols[0]
        let expected = "\(weekdaySymbol) 12:00 (Kyiv)"
        XCTAssertEqual(sut.formatted(schedule, timezone: "Europe/Kyiv"),
                       expected)
    }

    func testFormattedWithEmptyOrInvalidTimezoneIdentifierDoesNotAppendSuffix() {
        let schedule = makeSchedule(weekday: 1, time: "12:00")
        let weekdaySymbol = Calendar.current.weekdaySymbols[0]
        let expected = "\(weekdaySymbol) 12:00"
        XCTAssertEqual(sut.formatted(schedule, timezone: ""), expected)
    }
}
