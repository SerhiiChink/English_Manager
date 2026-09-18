//
//  PaymentFormatterTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 16.09.2026.
//

import XCTest
@testable import English_Manager

final class PaymentFormatterTests: XCTestCase {
    // MARK: - Properties
    private var sut: PaymentFormatter!

    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        sut = PaymentFormatter()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Helpers
    private func makePaymentRequest(
        amount: Double = 1000.0,
        status: PaymentStatus = .confirmed,
        lessonsCount: Int = 4,
        confirmedLessons: Int? = nil,
        createdAt: Date = Date()
    ) -> PaymentRequest {
        PaymentRequest(
            id: "pay_123",
            studentId: "student_123",
            teacherId: "teacher_123",
            studentName: "Test Student",
            lessonsCount: lessonsCount,
            confirmedLessons: confirmedLessons,
            amount: amount,
            status: status,
            createdAt: createdAt,
            confirmedAt: nil,
            hiddenForTeacher: nil,
            hiddenForStudent: nil
        )
    }

    private func makeTeacherSettings(
        lessonPrice: Double = 500.0,
        currency: String = "UAH",
        minLessons: Int = 4
    ) -> TeacherSettings {
        TeacherSettings(
            teacherId: "teacher_123",
            lessonPrice: lessonPrice,
            minLessons: minLessons,
            currency: currency
        )
    }

    private func makeDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.timeZone = TimeZone.current
        return Calendar.current.date(from: components) ?? Date()
    }

    // MARK: - Tests
    func testDateStringFormatsDateToDDMmmYYYY() {
        let date = makeDate(year: 2026, month: 4, day: 12)
        let payment = makePaymentRequest(createdAt: date)

        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        let expected = formatter.string(from: date)

        XCTAssertEqual(sut.dateString(payment), expected)
    }

    func testAmountStringFormatsAmountWithUAHCurrency() {
        let payment = makePaymentRequest(amount: 1500.0)
        XCTAssertEqual(sut.amountString(payment), "1500 UAH")
    }

    func testCellBalanceTextFormatsLessonsCountLocalizedString() {
        let expected = String(format: NSLocalizedString("lessons_count",
                                                        comment: ""), 5)
        XCTAssertEqual(sut.cellBalanceText(balance: 5), expected)
    }

    func testPriceTextFormatsLessonPriceAndCurrency() {
        let settings = makeTeacherSettings(lessonPrice: 400.0,
                                           currency: "USD")
        XCTAssertEqual(sut.priceText(settings: settings), "400 USD")
    }

    func testMinLessonsTextFormatsMinLessonsWithLocalizedSuffix() {
        let settings = makeTeacherSettings(minLessons: 3)
        let expected = "3 \("lessons".localized)"
        XCTAssertEqual(sut.minLessonsText(settings: settings), expected)
    }

    func testDetailTextWhenConfirmedLessonsNilUsesLessonsCountAndStatus() {
        let payment = makePaymentRequest(status: .pending,
                                         lessonsCount: 4,
                                         confirmedLessons: nil)
        let statusStyle = PaymentStatusMapper.style(for: .pending)
        let expected = "4 \("lessons".localized) · \(statusStyle.text)"
        XCTAssertEqual(sut.detailText(payment), expected)
    }

    func testDetailTextWhenConfirmedLessonsNotNilUsesConfirmedLessonsAndStatus() {
        let payment = makePaymentRequest(status: .confirmed,
                                         lessonsCount: 4,
                                         confirmedLessons: 2)
        let statusStyle = PaymentStatusMapper.style(for: .confirmed)
        let expected = "2 \("lessons".localized) · \(statusStyle.text)"
        XCTAssertEqual(sut.detailText(payment), expected)
    }

    func testPaymentAlertMessageFormatsPriceAndMinimumText() {
        let settings = makeTeacherSettings(lessonPrice: 500.0,
                                           currency: "UAH",
                                           minLessons: 4)
        let expected = "\("price".localized): 500 UAH/\("lesson".localized)\n\("minimum".localized): 4 \("lessons".localized)"
        XCTAssertEqual(sut.paymentAlertMessage(settings: settings), expected)
    }

    func testInvalidAmountMessageFormatsMinimumPaymentText() {
        let settings = makeTeacherSettings(minLessons: 4)
        let expected = "\("minimum_payment".localized): 4 \("lessons".localized)"
        XCTAssertEqual(sut.invalidAmountMessage(settings: settings), expected)
    }

    func testTotalReceivedTextFormatsTotalReceivedAmount() {
        let expected = "\("total_received".localized) 2500 UAH"
        XCTAssertEqual(sut.totalReceivedText(amount: 2500.0), expected)
    }

    func testTotalPaidTextFormatsTotalPaidAmount() {
        let expected = "\("total_paid".localized) 2500 UAH"
        XCTAssertEqual(sut.totalPaidText(amount: 2500.0), expected)
    }
}
