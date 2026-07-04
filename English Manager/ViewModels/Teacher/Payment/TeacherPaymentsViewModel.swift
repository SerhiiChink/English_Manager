//
//  TeacherPaymentsViewModel.swift
//  English Manager
//
//  Created by Sergej Klepikov on 10.04.2026.
//

import Foundation

protocol TeacherPaymentsViewModelProtocol: AnyObject {
    var onUpdate: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var onLoading: ((Bool) -> Void)? { get set }
    var students: [User] { get }
    var settings: TeacherSettings? { get }
    func fetchData()
    func saveSettings(price: Double, minLessons: Int, currency: String)
    func cellMode(for student: User) -> PaymentCellModel
}

final class TeacherPaymentsViewModel: TeacherPaymentsViewModelProtocol {
    // MARK: - Callbacks
    var onUpdate: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoading: ((Bool) -> Void)?
    
    // MARK: - Data
    private(set) var students: [User] = []
    private var payments: [PaymentRequest] = []
    private(set) var settings: TeacherSettings?
    private var isFetching = false
    
    // MARK: - Properties
    private let paymentService: PaymentFirestoreServiceProtocol
    private let firestoreService: FirestoreServiceProtocol
    private let authService: AuthServiceProtocol
    private let formatter: PaymentFormatterProtocol = PaymentFormatter()
    
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
                async let settings = paymentService
                    .fetchSettings(teacherId: teacherId)
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
    
    // MARK: - Settings
    func saveSettings(price: Double, minLessons: Int, currency: String) {
        guard let teacherId = authService.currentUserId else { return }
        let settings = TeacherSettings(
            teacherId: teacherId,
            lessonPrice: price,
            minLessons: minLessons,
            currency: currency,
            showAutoDebitPrompt: self.settings?.showAutoDebitPrompt ?? true
        )
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
    
    // MARK: - Cell Mode
    func cellMode(for student: User) -> PaymentCellModel {
        let balance = student.lessonsBalance ?? 0
        let hasPending = payments.contains {
            $0.studentId == student.id && $0.status == .pending
        }
        return PaymentCellModel(
            name: student.displayName,
            balanceLevel: BalanceLevelMapper.level(
                balance: balance,
                minLessons: settings?.minLessons ?? 1
            ),
            hasPending: hasPending,
            balanceText: formatter.cellBalanceText(balance: balance),
            photoURL: student.photoURL
        )
    }
}
