//
//  PaymentReviewViewModelTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 16.08.2026.
//

import XCTest
@testable import English_Manager

final class PaymentReviewViewModelTests: XCTestCase {
    // MARK: - Properties
    private var sut: PaymentReviewViewModel!
    private var initialPayment: PaymentRequest!
    private var settings: TeacherSettings!

    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        initialPayment = PaymentRequest(studentId: "s_1",
                                        teacherId: "t_1",
                                        studentName: "Anna",
                                        lessonsCount: 5,
                                        amount: 100.0,
                                        status: .pending,
                                        createdAt: Date())
        settings = TeacherSettings(teacherId: "t_1",
                                   lessonPrice: 20.0,
                                   minLessons: 2,
                                   currency: "USD")
        sut = PaymentReviewViewModel(payment: initialPayment,
                                     settings: settings)
    }

    override func tearDown() {
        sut = nil
        initialPayment = nil
        settings = nil
        super.tearDown()
    }

    // MARK: - Lessons Count Logic Tests
    func testLessonsCountReturnsDefaultLessonsCountWhenConfirmedLessonsIsNil() {
        XCTAssertEqual(sut.lessonsCount, 5)
    }

    func testLessonsCountReturnsConfirmedLessonsWhenPresent() {
        var updatedPayment = initialPayment!
        updatedPayment.confirmedLessons = 10
        sut.updatePayment(updatedPayment)
        XCTAssertEqual(sut.lessonsCount, 10)
    }

    // MARK: - Actions Tests
    func testConfirmTappedTriggersOnConfirmCallback() {
        var confirmCalled = false
        sut.onConfirm = { confirmCalled = true }
        sut.confirmTapped()
        XCTAssertTrue(confirmCalled)
    }

    func testRejectTappedTriggersOnRejectCallback() {
        var rejectCalled = false
        sut.onReject = { rejectCalled = true }
        sut.rejectTapped()
        XCTAssertTrue(rejectCalled)
    }

    func testEditTappedTriggersOnEditCallbackWithNewCount() {
        var editedCount: Int?
        sut.onEdit = { count in editedCount = count }
        sut.editTapped(newCount: 8)
        XCTAssertEqual(editedCount, 8)
    }

    func testUpdatePaymentUpdatesPaymentAndTriggersOnUpdate() {
        var updateCalled = false
        sut.onUpdate = { updateCalled = true }
        var newPayment = initialPayment!
        newPayment.amount = 150.0
        sut.updatePayment(newPayment)
        XCTAssertEqual(sut.payment.amount, 150.0)
        XCTAssertTrue(updateCalled)
    }
}
