//
//  TeacherPaymentsViewModelTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 16.08.2026.
//

import XCTest
@testable import English_Manager

@MainActor
final class TeacherPaymentsViewModelTests: XCTestCase {
    // MARK: - Properties
    private var sut: TeacherPaymentsViewModel!
    private var mockAuthService: MockAuthService!
    private var mockFirestoreService: MockFirestoreService!
    private var mockPaymentService: MockPaymentFirestoreService!
    
    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
        mockFirestoreService = MockFirestoreService()
        mockPaymentService = MockPaymentFirestoreService()
        sut = TeacherPaymentsViewModel(
            paymentService: mockPaymentService,
            firestoreService: mockFirestoreService,
            authService: mockAuthService
        )
    }

    override func tearDown() {
        sut = nil
        mockAuthService = nil
        mockFirestoreService = nil
        mockPaymentService = nil
        super.tearDown()
    }
    
    // MARK: - Fetch Data Tests
    func testFetchDataWhenUserNotLoggedInDoesNothing() {
        mockAuthService.currentUserId = nil
        var updateCalled = false
        sut.onUpdate = { updateCalled = true }
        sut.fetchData()
        XCTAssertFalse(updateCalled)
        XCTAssertTrue(sut.students.isEmpty)
        XCTAssertNil(sut.settings)
    }

    func testFetchDataSuccessfullyLoadsStudentsPaymentsAndSettings() async {
        let teacherId = "teacher_123"
        let studentId = "student_999"
        mockAuthService.currentUserId = teacherId
        var student = User(id: studentId, name: "Anna", surname: "Smith", email: "a@e.com", teacherId: teacherId)
        student.role = .student
        mockFirestoreService.users[studentId] = student
        var pendingPayment = PaymentRequest(
            studentId: studentId,
            teacherId: teacherId,
            studentName: "Anna Smith",
            lessonsCount: 5,
            amount: 50.0,
            status: .pending,
            createdAt: Date()
        )
        pendingPayment.id = "pay_1"
        mockPaymentService.payments["pay_1"] = pendingPayment
        let settings = TeacherSettings(teacherId: teacherId, lessonPrice: 20.0, minLessons: 2, currency: "USD")
        mockPaymentService.settings[teacherId] = settings
        var loadingStates: [Bool] = []
        let expUpdate = expectation(description: "Fetch completed")
        sut.onLoading = { loadingStates.append($0) }
        sut.onUpdate = { expUpdate.fulfill() }
        sut.fetchData()
        await fulfillment(of: [expUpdate], timeout: 2.0)
        XCTAssertEqual(sut.students.count, 1)
        XCTAssertEqual(sut.students.first?.id, studentId)
        XCTAssertEqual(sut.settings?.lessonPrice, 20.0)
        XCTAssertEqual(sut.pendingCount, 1)
        XCTAssertEqual(loadingStates, [true, false])
    }

    func testFetchDataWhenFirestoreFailsTriggersError() async {
        let teacherId = "teacher_123"
        mockAuthService.currentUserId = teacherId
        mockPaymentService.shouldReturnError = true
        mockFirestoreService.shouldReturnError = true
        let expError = expectation(description: "Fetch error triggered")
        var errorMessage: String?
        sut.onError = { error in
            errorMessage = error
            expError.fulfill()
        }
        sut.fetchData()
        await fulfillment(of: [expError], timeout: 2.0)
        XCTAssertNotNil(errorMessage)
    }

    // MARK: - Save Settings Tests
    func testSaveSettingsSuccessfullyUpdatesSettings() async {
        let teacherId = "teacher_123"
        mockAuthService.currentUserId = teacherId
        var loadingStates: [Bool] = []
        let expUpdate = expectation(description: "Save settings completed")
        sut.onLoading = { loadingStates.append($0) }
        sut.onUpdate = { expUpdate.fulfill() }
        sut.saveSettings(price: 25.0, minLessons: 3, currency: "EUR")
        await fulfillment(of: [expUpdate], timeout: 2.0)
        XCTAssertEqual(sut.settings?.lessonPrice, 25.0)
        XCTAssertEqual(sut.settings?.minLessons, 3)
        XCTAssertEqual(sut.settings?.currency, "EUR")
        XCTAssertEqual(loadingStates, [true, false])
        XCTAssertEqual(mockPaymentService.saveSettingsCalledWith?.teacherId, teacherId)
    }

    func testSaveSettingsWhenErrorOccursTriggersErrorCallback() async {
        let teacherId = "teacher_123"
        mockAuthService.currentUserId = teacherId
        mockPaymentService.shouldReturnError = true
        let expError = expectation(description: "Save settings error")
        var errorMessage: String?
        sut.onError = { error in
            errorMessage = error
            expError.fulfill()
        }
        sut.saveSettings(price: 30.0, minLessons: 1, currency: "USD")
        await fulfillment(of: [expError], timeout: 2.0)
        XCTAssertNotNil(errorMessage)
    }

    // MARK: - Cell Mode Tests
    func testCellModeReturnsCorrectModelForStudent() async {
        let teacherId = "teacher_123"
        let studentId = "student_999"
        mockAuthService.currentUserId = teacherId
        var student = User(id: studentId, name: "Anna", surname: "Smith", email: "a@e.com", teacherId: teacherId)
        student.role = .student
        student.lessonsBalance = 5
        mockFirestoreService.users[studentId] = student
        var pendingPayment = PaymentRequest(
            studentId: studentId,
            teacherId: teacherId,
            studentName: "Anna Smith",
            lessonsCount: 5,
            amount: 50.0,
            status: .pending,
            createdAt: Date()
        )
        pendingPayment.id = "pay_1"
        mockPaymentService.payments["pay_1"] = pendingPayment
        let fetchExp = expectation(description: "Fetch completed")
        sut.onUpdate = { fetchExp.fulfill() }
        sut.fetchData()
        await fulfillment(of: [fetchExp], timeout: 2.0)
        let cellModel = sut.cellMode(for: student)
        XCTAssertEqual(cellModel.name, student.displayName)
        XCTAssertTrue(cellModel.hasPending)
    }
}
