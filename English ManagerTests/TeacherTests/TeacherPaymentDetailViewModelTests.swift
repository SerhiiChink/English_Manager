//
//  TeacherPaymentDetailViewModelTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 16.08.2026.
//

import XCTest
@testable import English_Manager
 
@MainActor
final class TeacherPaymentDetailViewModelTests: XCTestCase {
    // MARK: - Properties
    private var sut: TeacherPaymentDetailViewModel!
    private var mockAuthService: MockAuthService!
    private var mockFirestoreService: MockFirestoreService!
    private var mockPaymentService: MockPaymentFirestoreService!
    private var student: User!
 
    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
        mockFirestoreService = MockFirestoreService()
        mockPaymentService = MockPaymentFirestoreService()
        student = makeStudent()
        mockFirestoreService.users[student.id] = student
        sut = TeacherPaymentDetailViewModel(
            student: student,
            paymentService: mockPaymentService,
            authService: mockAuthService,
            firestoreService: mockFirestoreService
        )
    }
 
    override func tearDown() {
        sut = nil
        mockAuthService = nil
        mockFirestoreService = nil
        mockPaymentService = nil
        student = nil
        super.tearDown()
    }
 
    // MARK: - Helpers
    private func makePayment(
        id: String = "pay_1",
        status: PaymentStatus = .pending,
        lessonsCount: Int = 5,
        amount: Double = 100.0
    ) -> PaymentRequest {
        var payment = PaymentRequest(
            studentId: student.id,
            teacherId: "teacher_123",
            studentName: "John Doe",
            lessonsCount: lessonsCount,
            amount: amount,
            status: status,
            createdAt: Date()
        )
        payment.id = id
        return payment
    }
    
    private func makeStudent() -> User {
        var student = User(
            id: "student_123",
            name: "John",
            surname: "Doe",
            email: "j@d.com",
            role: .student,
            teacherId: "teacher_123"
        )
        student.lessonsBalance = 3
        return student
    }
 
    private func fetchData() async {
        mockAuthService.currentUserId = "teacher_123"
        let exp = expectation(description: "Fetch completed")
        sut.onUpdate = { exp.fulfill() }
        sut.fetchData()
        await fulfillment(of: [exp], timeout: 2.0)
    }
 
    // MARK: - Fetch Data Tests
    func testFetchData_whenUserNotLoggedIn_doesNothing() {
        mockAuthService.currentUserId = nil
        var updateCalled = false
        sut.onUpdate = { updateCalled = true }
        sut.fetchData()
        XCTAssertFalse(updateCalled)
        XCTAssertTrue(sut.payments.isEmpty)
        XCTAssertNil(sut.settings)
    }
 
    func testFetchData_success_loadsPaymentsAndSettings() async {
        let payment = makePayment()
        mockPaymentService.payments[payment.id!] = payment
        let settings = TeacherSettings(teacherId: "teacher_123",
                                       lessonPrice: 20.0,
                                       minLessons: 2,
                                       currency: "USD")
        mockPaymentService.settings["teacher_123"] = settings
        var loadingStates: [Bool] = []
        sut.onLoading = { loadingStates.append($0) }
        await fetchData()
        XCTAssertEqual(sut.payments.count, 1)
        XCTAssertEqual(sut.settings?.lessonPrice, 20.0)
        XCTAssertEqual(loadingStates, [true, false])
    }
 
    func testFetchData_whenError_triggersOnError() async {
        mockAuthService.currentUserId = "teacher_123"
        mockPaymentService.shouldReturnError = true
        let exp = expectation(description: "Fetch error")
        var errorMessage: String?
        sut.onError = { error in
            errorMessage = error
            exp.fulfill()
        }
        sut.fetchData()
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertNotNil(errorMessage)
    }
 
    // MARK: - Confirm Payment Tests
    func testConfirmPayment_updatesStatusAndStudentBalance() async {
        let payment = makePayment()
        mockPaymentService.payments[payment.id!] = payment
        await fetchData()
        let exp = expectation(description: "Confirm completed")
        sut.onUpdate = { exp.fulfill() }
        sut.confirmPayment()
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertNil(sut.pendingPayment)
        XCTAssertEqual(sut.historyPayments.count, 1)
        XCTAssertEqual(sut.historyPayments.first?.status, .confirmed)
        XCTAssertEqual(sut.student.lessonsBalance, 8)
        XCTAssertEqual(mockPaymentService.confirmPaymentCalledWith?.id,
                       "pay_1")
    }
 
    // MARK: - Reject Payment Tests
    func testRejectPayment_updatesStatusToRejected() async {
        let payment = makePayment()
        mockPaymentService.payments[payment.id!] = payment
        await fetchData()
        let exp = expectation(description: "Reject completed")
        sut.onUpdate = { exp.fulfill() }
        sut.rejectPayment()
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertNil(sut.pendingPayment)
        XCTAssertEqual(sut.historyPayments.first?.status, .rejected)
        XCTAssertTrue(mockPaymentService.updatePaymentCalled)
    }
 
    // MARK: - Update Payment Lessons Tests
    func testUpdatePaymentLessons_updatesPaymentInArray() async {
        let payment = makePayment()
        mockPaymentService.payments[payment.id!] = payment
        await fetchData()
        guard var updatedPayment = sut.payments.first else {
            XCTFail("No payments loaded")
            return
        }
        updatedPayment.confirmedLessons = 10
        let exp = expectation(description: "Update completed")
        sut.onUpdate = { exp.fulfill() }
        sut.updatePaymentLessons(updatedPayment)
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertEqual(sut.payments.first?.confirmedLessons, 10)
        XCTAssertTrue(mockPaymentService.updatePaymentCalled)
    }
 
    // MARK: - Adjust Balance Tests
    func testAdjustBalance_updatesStudentBalanceAndCallsSuccess() async {
        mockAuthService.currentUserId = "teacher_123"
        let expSuccess = expectation(description: "Success triggered")
        let expUpdate = expectation(description: "Update triggered")
        var successMessage: String?
        sut.onSuccess = { msg in
            successMessage = msg
            expSuccess.fulfill()
        }
        sut.onUpdate = { expUpdate.fulfill() }
        sut.adjustBalance(to: 10)
        await fulfillment(of: [expSuccess, expUpdate], timeout: 2.0)
        XCTAssertEqual(sut.student.lessonsBalance, 10)
        XCTAssertNotNil(successMessage)
        XCTAssertEqual(mockFirestoreService.users[student.id]?.lessonsBalance,
                       10)
    }
 
    // MARK: - Clear History Tests
    func testClearHistory_removesNonPendingPayments() async {
        let pending = makePayment(id: "pay_1", status: .pending)
        let confirmed = makePayment(id: "pay_2", status: .confirmed)
        mockPaymentService.payments[pending.id!] = pending
        mockPaymentService.payments[confirmed.id!] = confirmed
        await fetchData()
        let exp = expectation(description: "Clear history completed")
        sut.onUpdate = { exp.fulfill() }
        sut.clearHistory()
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertEqual(sut.payments.count, 1)
        XCTAssertEqual(sut.payments.first?.id, "pay_1")
        XCTAssertEqual(mockPaymentService.hidePaymentsCalledWith?.ids,
                       ["pay_2"])
        XCTAssertEqual(mockPaymentService.hidePaymentsCalledWith?.forTeacher,
                       true)
    }
}
