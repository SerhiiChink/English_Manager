//
//  StudentPaymentsViewModelTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 15.08.2026.
//

import XCTest
@testable import English_Manager

@MainActor
final class StudentPaymentsViewModelTests: XCTestCase {
    // MARK: - Properties
    private var sut: StudentPaymentsViewModel!
    private var mockAuthService: MockAuthService!
    private var mockFirestoreService: MockFirestoreService!
    private var mockPaymentService: MockPaymentFirestoreService!
    private var mockUserCache: MockUserCache!
    
    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
        mockFirestoreService = MockFirestoreService()
        mockPaymentService = MockPaymentFirestoreService()
        mockUserCache = MockUserCache()
        sut = StudentPaymentsViewModel(
            paymentService: mockPaymentService,
            firestoreService: mockFirestoreService,
            authService: mockAuthService,
            cache: mockUserCache
        )
    }

    override func tearDown() {
        sut = nil
        mockAuthService = nil
        mockFirestoreService = nil
        mockPaymentService = nil
        mockUserCache = nil
        super.tearDown()
    }

    // MARK: - Fetch Tests
    func testFetchDataSuccessfullyLoadsUserAndPayments() async {
        let studentId = "student_123"
        mockAuthService.currentUserId = studentId
        mockFirestoreService.users[studentId] = User(
            id: studentId,
            name: "Anna",
            surname: "Smith",
            email: "a@e.com", 
            teacherId: "teacher_999"
        )
        let exp = expectation(description: "Fetch completed")
        sut.onUpdate = { exp.fulfill() }
        sut.fetchData()
        await fulfillment(of: [exp], timeout: 1.0)
        XCTAssertEqual(sut.currentUser?.id, studentId)
    }

    // MARK: - Create Payment Tests
    func testCreatePaymentWhenNoSettingsTriggersError() async {
        let studentId = "student_123"
        mockAuthService.currentUserId = studentId
        mockFirestoreService.users[studentId] = User(
            id: studentId,
            name: "Anna",
            surname: "Smith",
            email: "a@e.com", 
            teacherId: "teacher_999"
        )
        let fetchExp = expectation(description: "Fetch completed")
        sut.onUpdate = { fetchExp.fulfill() }
        sut.fetchData()
        await fulfillment(of: [fetchExp], timeout: 1.0)
        var errorMessage: String?
        sut.onError = { error in errorMessage = error }
        sut.createPayment(lessonsCount: 5)
        XCTAssertEqual(errorMessage, "Payment settings not configured")
    }

    // MARK: - Clear History Tests
    func testClearHistoryRemovesNonPendingPayments() async {
        let studentId = "student_123"
        mockAuthService.currentUserId = studentId
        mockFirestoreService.users[studentId] = User(
            id: studentId,
            name: "Anna",
            surname: "Smith",
            email: "a@e.com"
        )
        var confirmedPayment = PaymentRequest(
            studentId: studentId,
            teacherId: "teacher_1",
            studentName: "Anna Smith",
            lessonsCount: 5,
            amount: 50.0,
            status: .confirmed,
            createdAt: Date()
        )
        confirmedPayment.id = "pay_1"
        mockPaymentService.payments["pay_1"] = confirmedPayment
        let fetchExp = expectation(description: "Fetch completed")
        sut.onUpdate = { fetchExp.fulfill() }
        sut.fetchData()
        await fulfillment(of: [fetchExp], timeout: 1.0)
        let clearExp = expectation(description: "Clear completed")
        sut.onUpdate = { clearExp.fulfill() }
        sut.clearHistory()
        await fulfillment(of: [clearExp], timeout: 1.0)
        XCTAssertTrue(sut.payments.isEmpty)
    }
}
