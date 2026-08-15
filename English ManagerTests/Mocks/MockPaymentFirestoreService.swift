//
//  MockPaymentFirestoreService.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 12.08.2026.
//

import Foundation
@testable import English_Manager

final class MockPaymentFirestoreService: PaymentFirestoreServiceProtocol {
    // MARK: - In-Memory Storage
    var payments: [String: PaymentRequest] = [:]
    var settings: [String: TeacherSettings] = [:]
    
    // MARK: - Error Simulation
    var shouldReturnError = false
    var customError: Error = NSError(
        domain: "PaymentFirestoreError",
        code: -1,
        userInfo: [NSLocalizedDescriptionKey: "Mock Payment Firestore Error"]
    )
    
    // MARK: - Call Trackers
    private(set) var savePaymentCalled = false
    private(set) var updatePaymentCalled = false
    private(set) var confirmPaymentCalledWith: PaymentRequest?
    private(set) var deletePaymentCalledWith: String?
    private(set) var hidePaymentsCalledWith: (ids: [String], forTeacher: Bool)?
    private(set) var saveSettingsCalledWith: TeacherSettings?
    private func checkError() throws {
        if shouldReturnError {
            throw customError
        }
    }
    
    // MARK: - Payments
    func savePayment(_ payment: PaymentRequest) async throws {
        try checkError()
        savePaymentCalled = true
        var updatedPayment = payment
        let id = payment.id ?? UUID().uuidString
        updatedPayment.id = id
        payments[id] = updatedPayment
    }
    
    func fetchPayments(teacherId: String) async throws -> [PaymentRequest] {
        try checkError()
        return payments.values.filter { $0.teacherId == teacherId }
    }
    
    func fetchStudentPayments(studentId: String) async throws -> [PaymentRequest] {
        try checkError()
        return payments.values.filter {
            $0.studentId == studentId &&
            $0.hiddenForStudent != true
        }
    }
    
    func fetchPaymentsForStudent(studentId: String,
                                 teacherId: String) async throws -> [PaymentRequest] {
        try checkError()
        return payments.values.filter {
            $0.studentId == studentId &&
            $0.teacherId == teacherId &&
            $0.hiddenForTeacher != true
        }
    }
    
    func updatePayment(_ payment: PaymentRequest) async throws {
        try checkError()
        updatePaymentCalled = true
        guard let id = payment.id else { return }
        payments[id] = payment
    }
    
    func confirmPaymant(_ paymant: PaymentRequest) async throws {
        try checkError()
        confirmPaymentCalledWith = paymant
        guard let id = paymant.id else {
            throw NSError(
                domain: "PaymantError",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Missing payment id"]
            )
        }
        guard paymant.status == .pending else { return }
        var confirmed = paymant
        confirmed.status = .confirmed
        confirmed.confirmedAt = Date()
        payments[id] = confirmed
    }
    
    func deletePayment(id: String) async throws {
        try checkError()
        deletePaymentCalledWith = id
        payments.removeValue(forKey: id)
    }
    
    func hidePayments(ids: [String], forTeacher: Bool) async throws {
        try checkError()
        hidePaymentsCalledWith = (ids, forTeacher)
        ids.forEach { id in
            if forTeacher {
                payments[id]?.hiddenForTeacher = true
            } else {
                payments[id]?.hiddenForStudent = true
            }
        }
    }
    
    // MARK: - Settings
    func saveSettings(_ settigns: TeacherSettings) async throws {
        try checkError()
        saveSettingsCalledWith = settigns
        settings[settigns.teacherId] = settigns
    }
    
    func fetchSettings(teacherId: String) async throws -> TeacherSettings? {
        try checkError()
        return settings[teacherId]
    }
}
