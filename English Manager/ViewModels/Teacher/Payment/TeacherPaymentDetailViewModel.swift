//
//  TeacherPaymentDetailViewModel.swift
//  English Manager
//
//  Created by Sergej Klepikov on 13.04.2026.
//

import Foundation

protocol TeacherPaymentDetailViewModelProtocol: AnyObject {
    var onUpdate: (() -> Void)? { get set }
    var onSuccess: ((String) -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var onLoading: ((Bool) -> Void)? { get set }
    var onAutoDebitSuggestion: (() -> Void)? { get set }
    var student: User { get }
    var payments: [PaymentRequest] { get }
    var settings: TeacherSettings? { get }
    var pendingPayment: PaymentRequest? { get }
    var historyPayments: [PaymentRequest] { get }
    var totalConfirmed: Double { get }
    var accountStatusStyle: AccountStatusStyle { get }
    var balanceText: String { get }
    var lastPaymentDateText: String? { get }
    var lastPaymentLessonsText: String? { get }
    var lastPaymentAmountText: String? { get }
    var totalConfirmedText: String { get }
    var shouldShowAutoDebitBanner: Bool { get }
    func fetchData()
    func confirmPayment()
    func rejectPayment()
    func updatePaymentLessons(_ payment: PaymentRequest)
    func adjustBalance(to newBalance: Int)
    func clearHistory()
}

final class TeacherPaymentDetailViewModel: TeacherPaymentDetailViewModelProtocol {
    // MARK: - Callbacks
    var onUpdate: (() -> Void)?
    var onSuccess: ((String) -> Void)?
    var onError: ((String) -> Void)?
    var onLoading: ((Bool) -> Void)?
    var onAutoDebitSuggestion: (() -> Void)?
    
    // MARK: - Data
    private(set) var student: User
    private(set) var payments: [PaymentRequest] = []
    private(set) var settings: TeacherSettings?
    private var isFetching = false
    
    // MARK: - Computed
    var pendingPayment: PaymentRequest? {
        payments.first { $0.status == .pending }
    }

    var historyPayments: [PaymentRequest] {
        payments.filter { $0.status != .pending }
    }

    var totalConfirmed: Double {
        historyPayments
            .filter { $0.status == .confirmed }
            .reduce(0) { $0 + $1.amount }
    }
    
    var accountStatusStyle: AccountStatusStyle {
        AccountStatusMapper.style(
            balance: student.lessonsBalance ?? 0,
            hasPending: pendingPayment != nil,
            minLessons: settings?.minLessons ?? 1
        )
    }
    
    var balanceText: String {
        formatter.cellBalanceText(balance: student.lessonsBalance ?? 0)
    }
    
    var lastPaymentDateText: String? {
        guard let last = pendingPayment ?? historyPayments.first else {
            return nil
        }
        return formatter.dateString(last)
    }
    
    var lastPaymentLessonsText: String? {
        guard let last = pendingPayment ?? historyPayments.first else {
            return nil
        }
        return "\(last.confirmedLessons ?? last.lessonsCount)"
    }
    
    var lastPaymentAmountText: String? {
        guard let last = pendingPayment ?? historyPayments.first else {
            return nil
        }
        return formatter.amountString(last)
    }
    
    var totalConfirmedText: String {
        formatter.totalReceivedText(amount: totalConfirmed)
    }
    
    var shouldShowAutoDebitBanner: Bool {
        !(student.isAutoDebitEnabled ?? false)
    }

        
    // MARK: - Properties
    private let paymentService: PaymentFirestoreServiceProtocol
    private let authService: AuthServiceProtocol
    private let firestoreService: FirestoreServiceProtocol
    private let formatter: PaymentFormatterProtocol
    
    // MARK: - Init
    init(
        student: User,
        paymentService: PaymentFirestoreServiceProtocol = PaymentFirestoreService(),
        authService: AuthServiceProtocol = AuthService(),
        firestoreService: FirestoreServiceProtocol = FirestoreService(),
        formatter: PaymentFormatterProtocol = PaymentFormatter()
    ) {
        self.student = student
        self.paymentService = paymentService
        self.authService = authService
        self.firestoreService = firestoreService
        self.formatter = formatter
    }
    
    // MARK: - Fetch
    func fetchData() {
        guard !isFetching else { return }
        guard let teaherId = authService.currentUserId else { return }
        isFetching = true
        onLoading?(true)
        Task {
            do {
                async let payments = paymentService
                    .fetchPaymentsForStudent(studentId: student.id,
                                             teacherId: teaherId)
                async let settings = paymentService
                    .fetchSettings(teacherId: teaherId)
                let (fetchedPayments,
                     fetchedSettings) = try await (payments, settings)
                await MainActor.run { [weak self] in
                    self?.payments = fetchedPayments
                    self?.settings = fetchedSettings
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
    func confirmPayment() {
        guard let payment = pendingPayment else { return }
        onLoading?(true)
        Task {
            do {
                try await paymentService.confirmPaymant(payment)
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    if let index = payments.firstIndex(
                        where: { $0.id == payment.id }
                    ) {
                        var confirmed = payments[index]
                        confirmed.status = .confirmed
                        confirmed.confirmedAt = Date()
                        confirmed.confirmedLessons = payment.confirmedLessons ?? payment.lessonsCount
                        payments[index] = confirmed
                        let addedLessons = payment.confirmedLessons ?? payment.lessonsCount
                        student.lessonsBalance = (student.lessonsBalance ?? 0) + addedLessons
                    }
                    onLoading?(false)
                    onUpdate?()
                    if shouldShowAutoDebitBanner {
                        onAutoDebitSuggestion?()
                    }
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
    func rejectPayment() {
        guard var payment = pendingPayment else { return }
        payment.status = .rejected
        onLoading?(true)
        Task {
            do {
                try await paymentService.updatePayment(payment)
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    if let index = payments.firstIndex(
                        where: { $0.id == payment.id }
                    ) {
                        payments[index].status = .rejected
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
    
    // MARK: - Update
    func updatePaymentLessons(_ payment: PaymentRequest) {
        onLoading?(true)
        Task {
            do {
                try await paymentService.updatePayment(payment)
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    if let index = payments.firstIndex(
                        where: { $0.id == payment.id }
                    ) {
                        payments[index] = payment
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
    
    // MARK: - Balance and History
    func adjustBalance(to newBalance: Int) {
        onLoading?(true)
        Task {
            do {
                try await firestoreService
                    .setLessonsBalance(studentId: student.id,
                                       balance: newBalance)
                await MainActor.run { [weak self] in
                    self?.student.lessonsBalance = newBalance
                    self?.onLoading?(false)
                    self?.onSuccess?("balance_adjusted".localized)
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
    
    func clearHistory() {
        let toDelete = historyPayments
        let ids = toDelete.compactMap { $0.id }
        onLoading?(true)
        Task {
            do {
                try await paymentService.hidePayments(ids: ids,
                                                      forTeacher: true)
                await MainActor.run { [weak self] in
                    self?.payments.removeAll { $0.status != .pending }
                    self?.onLoading?(false)
                    self?.onSuccess?("history_cleared".localized)
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
}
