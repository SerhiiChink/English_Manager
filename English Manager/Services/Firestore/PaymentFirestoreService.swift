//
//  PaymentFirestoreService.swift
//  English Manager
//
//  Created by Sergej Klepikov on 04.04.2026.
//

import UIKit
import FirebaseFirestore

protocol PaymentFirestoreServiceProtocol {
    func savePayment(_ payment: PaymentRequest) async throws
    func fetchPayments(teacherId: String) async throws -> [PaymentRequest]
    func fetchStudentPayments(studentId: String) async throws -> [PaymentRequest]
    func fetchPaymentsForStudent(studentId: String,
                                 teacherId: String) async throws -> [PaymentRequest]
    func updatePayment(_ payment: PaymentRequest) async throws
    func confirmPaymant(_ paymant: PaymentRequest) async throws
    func deletePayment(id: String) async throws
    func hidePayments(ids: [String], forTeacher: Bool) async throws
    func saveSettings(_ settigns: TeacherSettings) async throws
    func fetchSettings(teacherId: String)  async throws -> TeacherSettings?
}

final class PaymentFirestoreService: PaymentFirestoreServiceProtocol {
    // MARK: - Properties
    private let db = Firestore.firestore()
    
    // MARK: - Private helpers
    private func collection(_ name: String) -> CollectionReference {
        db.collection(name)
    }
    
    // MARK: - Payments
    func savePayment(_ payment: PaymentRequest) async throws {
        let id = payment.id ?? collection(Collections.payments)
            .document().documentID
        var payment = payment
        payment.id = id
        try collection(Collections.payments)
            .document(id)
            .setData(from: payment)
    }
    
    func fetchPayments(teacherId: String) async throws -> [PaymentRequest] {
        let snapshot = try await collection(Collections.payments)
            .whereField("teacherId", isEqualTo: teacherId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return try snapshot.decode(PaymentRequest.self)
    }
    
    func fetchStudentPayments(studentId: String) async throws -> [PaymentRequest] {
        let snapshot = try await collection(Collections.payments)
            .whereField("studentId", isEqualTo: studentId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return try snapshot.decode(PaymentRequest.self)
            .filter { $0.hiddenForStudent != true }
    }
    
    func fetchPaymentsForStudent(studentId: String,
                                 teacherId: String) async throws -> [PaymentRequest] {
        let snapshot = try await collection(Collections.payments)
            .whereField("studentId", isEqualTo: studentId)
            .whereField("teacherId", isEqualTo: teacherId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return try snapshot.decode(PaymentRequest.self)
            .filter { $0.hiddenForTeacher != true }
    }
 
    func updatePayment(_ payment: PaymentRequest) async throws {
        guard let id = payment.id else { return }
        try collection(Collections.payments)
            .document(id)
            .setData(from: payment)
    }
    
    func confirmPaymant(_ paymant: PaymentRequest) async throws {
        guard let id = paymant.id else {
            throw NSError(
                domain: "PaymantError",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Missing payment id"]
            )
        }
        guard paymant.status == .pending else { return }
        let count = Int64(paymant.confirmedLessons ?? paymant.lessonsCount)
        let batch = db.batch()
        var confirmed = paymant
        confirmed.status = .confirmed
        confirmed.confirmedAt = Date()
        let paymentRef = collection(Collections.payments).document(id)
        try batch.setData(from: confirmed, forDocument: paymentRef)
        let userRef = collection(Collections.users).document(paymant.studentId)
        batch.updateData([
            "lessonsBalance": FieldValue.increment(count),
            "totalLessonsPaid": FieldValue.increment(count)
        ], forDocument: userRef)
        try await batch.commit()
    }
    
    func deletePayment(id: String) async throws {
        try await collection(Collections.payments)
            .document(id).delete()
    }
    
    func hidePayments(ids: [String], forTeacher: Bool) async throws {
        let batch = db.batch()
        let field = forTeacher ? "hiddenForTeacher" : "hiddenForStudent"
        ids.forEach { id in
            let reference = collection(Collections.payments)
                .document(id)
            batch.updateData([field: true], forDocument: reference)
        }
        try await batch.commit()
    }
    
    // MARK: - Settings
    func saveSettings(_ settigns: TeacherSettings) async throws {
        try collection(Collections.teacherSettings)
            .document(settigns.teacherId)
            .setData(from: settigns)
    }
    
    func fetchSettings(teacherId: String)  async throws -> TeacherSettings? {
        let doc = try await collection(Collections.teacherSettings)
            .document(teacherId)
            .getDocument()
        guard doc.exists else { return nil }
        return try? doc.data(as: TeacherSettings.self)
    }
}
