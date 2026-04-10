//
//  TeacherPaymentsViewModel.swift
//  English Manager
//
//  Created by Sergej Klepikov on 10.04.2026.
//

import UIKit

protocol TeacherPaymentsViewModelProtocol: AnyObject {
    var onUpdate: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var onLoading: ((Bool) -> Void)? { get set }
    var students: [User] { get }
    var payments: [PaymentRequest] { get }
    var settings: TeacherSettings? { get }
    func fetchData()
    func confirmPayment(_ payment: PaymentRequest)
    func rejectPayment(_ payment: PaymentRequest)
    func adjustBalance(student: User, delta: Int)
    func saveSettings(price: Double, minLissons: Int, currency: String)
}

final class TeacherPaymentsViewModel: TeacherPaymentsViewModelProtocol {
    // MARK: - Callbacks
    var onUpdate: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoading: ((Bool) -> Void)?
    
    // MARK: - Data
    private(set) var students: [User] = []
    private(set) var payments: [PaymentRequest] = []
    private(set) var settings: TeacherSettings?
    private var isFetching = false
    
    // MARK: - Properties
    private let paymentService: PaymentFirestoreServiceProtocol
    private let firestoreService: FirestoreServiceProtocol
    private let authService: AuthServiceProtocol
    
    // MARK: - Init
    init(
        paymentService: PaymentFirestoreServiceProtocol = PaymentFirestoreService(),
        firestoreService: FirestoreServiceProtocol = FirestoreService(),
        authService: AuthServiceProtocol = AuthService()
    ) {
        self.paymentService = paymentService
        self.firestoreService = firestoreService
        self.authService = authService
    }
    
    // MARK: - Fetch
    func fetchData() {
        guard !isFetching else { return }
        guard let teacherId = authService.currentUserId else { return }
        isFetching = true
        onLoading?(true)
        Task {
            do {
                async let students = firestoreService
                    .fetchStudents(teacherId: teacherId)
                async let payments = paymentService
                    .fetchPayments(teacherId: teacherId)
                async let settings = paymentService.fetchSettings(teacherId: teacherId)
                let (student, payment, setting) = try await (students,
                                                             payments,
                                                             settings)
                await MainActor.run { [weak self] in
                    self?.students = student
                    self?.payments = payment
                    self?.settings = setting
                    self?.isFetching = false
                    self?.onLoading?(false)
                    self?.onUpdate?()
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.isFetching = false
                    self?.onLoading?(false)
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Confirm
    func confirmPayment(_ payment: PaymentRequest) {
        onLoading?(true)
        Task {
            do {
                try await paymentService.confirmPaymant(payment)
                let count = payment.confirmedLessons ?? payment.lessonsCount
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    if let index = payments.firstIndex(
                        where: { $0.id == payment.id }
                    ) {
                        payments[index].status = .confirmed
                        payments[index].confirmedAt = Date()
                    }
                    if let index = students.firstIndex(
                        where: { $0.id == payment.studentId }
                    ) {
                        students[index].lessonsBalance = (
                            students[index].lessonsBalance ?? 0) + count
                        students[index].totalLessonsPaid = (
                            students[index].totalLessonsPaid ?? 0) + count
                    }
                    onLoading?(false)
                    onUpdate?()
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.onLoading?(false)
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Reject
    func rejectPayment(_ payment: PaymentRequest) {
        var rejected = payment
        rejected.status = .rejected
        onLoading?(true)
        Task {
            do {
                try await paymentService.updatePayment(rejected)
                await MainActor.run { [weak self] in
                    if let index = self?.payments
                        .firstIndex(where: { $0.id == payment.id }) {
                        self?.payments[index].status = .rejected
                    }
                    self?.onLoading?(false)
                    self?.onUpdate?()
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.onLoading?(false)
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Manual Balance Adjust
    func adjustBalance(student: User, delta: Int) {
        onLoading?(true)
        Task {
            do {
                try await firestoreService.adjustLessonsBalance(
                    studentId: student.id,
                    delta: delta
                )
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    if let index = students.firstIndex(
                        where: { $0.id == student.id}
                    ) {
                        students[index].lessonsBalance = (
                            students[index].lessonsBalance ?? 0) + delta
                    }
                    onLoading?(false)
                    onUpdate?()
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.onLoading?(false)
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Settings
    func saveSettings(price: Double, minLissons: Int, currency: String) {
        guard let teacherId = authService.currentUserId else { return }
        let settings = TeacherSettings(teacherId: teacherId,
                                       lessonPrice: price,
                                       minLessons: minLissons,
                                       currency: currency)
        onLoading?(true)
        Task {
            do {
                try await paymentService.saveSettings(settings)
                await MainActor.run { [weak self] in
                    self?.settings = settings
                    self?.onLoading?(false)
                    self?.onUpdate?()
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.onLoading?(false)
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func payments(for studentId: String) -> [PaymentRequest] {
        payments.filter { $0.studentId == studentId }
    }
    
    private func pendingPayments(for studentId: String) -> [PaymentRequest] {
        payments.filter { $0.studentId == studentId && $0.status == .pending }
    }
    
    private func balance(for student: User) -> String {
        let balance = student.lessonsBalance ?? 0
        let total = student.totalLessonsPaid ?? 0
        return "\(balance)/\(total)"
    }
    
    private func balanceColor(for student: User) -> UIColor {
        let balance = student.lessonsBalance ?? 0
        let min = settings?.minLessons ?? 3
        if balance == 0 { return.appRed }
        if balance < min { return.appGold }
        if balance < min { return.appGreen }
        return .appGreen
    }
}
