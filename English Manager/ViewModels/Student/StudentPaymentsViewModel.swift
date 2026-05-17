//
//  StudentPaymentsViewModel.swift
//  English Manager
//
//  Created by Sergej Klepikov on 11.04.2026.
//

import Foundation

protocol StudentPaymentsViewModelProtocol: AnyObject {
    var onUpdate: (() -> Void)? { get set }
    var onSuccess: ((String) -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var onLoading: ((Bool) -> Void)? { get set }
    var payments: [PaymentRequest] { get }
    var settings: TeacherSettings? { get }
    var currentUser: User? { get }
    var hasPendingPayment: Bool { get }
    var balanceText: String { get }
    var accountStatusStyle: AccountStatusStyle { get }
    var totalPaidText: String { get }
    var priceText: String { get }
    var minLessonsText: String { get }
    var paymentAvailability: PaymentAvailability { get }
    func fetchData()
    func refresh()
    func createPayment(lessonsCount: Int)
    func clearHistory()
}

final class StudentPaymentsViewModel: StudentPaymentsViewModelProtocol {
    // MARK: - Callbacks
    var onUpdate: (() -> Void)?
    var onSuccess: ((String) -> Void)?
    var onError: ((String) -> Void)?
    var onLoading: ((Bool) -> Void)?
    
    // MARK: - Data
    private(set) var payments: [PaymentRequest] = []
    private(set) var settings: TeacherSettings?
    private(set) var currentUser: User?
    private var isFetching = false
    
    // MARK: - Computed
    var accountStatusStyle: AccountStatusStyle {
        AccountStatusMapper.style(
            balance: currentUser?.lessonsBalance ?? 0,
            hasPending: hasPendingPayment,
            minLessons: settings?.minLessons ?? 1
        )
    }
    
    var hasPendingPayment: Bool {
        payments.contains { $0.status == .pending }
    }
    
    var balanceText: String {
        formatter.cellBalanceText(balance: currentUser?.lessonsBalance ?? 0)
    }
    
    var totalPaidText: String {
        let total = payments
            .filter { $0.status == .confirmed }
            .reduce(0.0) { $0 + $1.amount }
        return formatter.totalPaidText(amount: total)
    }
    
    var priceText: String {
        guard let settings else { return "-" }
        return formatter.priceText(settings: settings)
    }
    
    var minLessonsText: String {
        guard let settings else { return "-" }
        return formatter.minLessonsText(settings: settings)
    }
    
    var paymentAvailability: PaymentAvailability {
        guard let settings, settings.lessonPrice > 0 else { return .unavailable }
        if settings.minLessons <= 0 { return .priceOnly(price: settings.lessonPrice) }
        return .full(price: settings.lessonPrice,
                     minLessons: settings.minLessons)
    }
    
    // MARK: - Properties
    private let paymentService: PaymentFirestoreServiceProtocol
    private let firestoreService: FirestoreServiceProtocol
    private let authService: AuthServiceProtocol
    private let formatter: PaymentFormatterProtocol
    
    // MARK: - Init
    init(
        paymentService: PaymentFirestoreServiceProtocol = PaymentFirestoreService(),
        firestoreService: FirestoreServiceProtocol = FirestoreService(),
        authService: AuthServiceProtocol = AuthService(),
        formatter: PaymentFormatterProtocol = PaymentFormatter()
    ) {
        self.paymentService = paymentService
        self.firestoreService = firestoreService
        self.authService = authService
        self.formatter = formatter
    }
    
    // MARK: - Fetch
    func fetchData() {
        performFetch(forceRefresh: false)
    }
    
    func refresh() {
        performFetch(forceRefresh: true)
    }
    
    // MARK: - Create Payment
    func createPayment(lessonsCount: Int) {
        guard let studentId = authService.currentUserId,
              let teacherId = currentUser?.teacherId else {
            onError?("No teacher assigned")
            return
        }
        guard let price = settings?.lessonPrice else {
            onError?("Payment settings not configured")
            return
        }
        let amount = Double(lessonsCount) * price
        let payment = PaymentRequest(
            studentId: studentId,
            teacherId: teacherId,
            studentName: currentUser?.displayName ?? "",
            lessonsCount: lessonsCount,
            amount: amount,
            status: .pending,
            createdAt: Date()
        )
        onLoading?(true)
        Task {
            do {
                try await paymentService.savePayment(payment)
                await MainActor.run { [weak self] in
                    self?.payments.insert(payment, at: 0)
                    self?.onLoading?(false)
                    self?.onUpdate?()
                }
            }  catch {
                await MainActor.run { [weak self] in
                    self?.onLoading?(false)
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    func clearHistory() {
        let ids = payments
            .filter { $0.status != .pending }
            .compactMap { $0.id }
        onLoading?(true)
        Task {
            do {
                try await paymentService.hidePayments(ids: ids,
                                                      forTeacher: false)
                await MainActor.run { [weak self] in
                    self?.payments.removeAll { $0.status != .pending }
                    self?.onLoading?(false)
//                    self?.onSuccess?("history_cleared".localized)
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
    
    // MARK: - Helper
    private func performFetch(forceRefresh: Bool) {
        guard !isFetching else { return }
        guard let studentId = authService.currentUserId else { return }
        if currentUser != nil { onUpdate?() }
        isFetching = true
        onLoading?(currentUser == nil)
        Task {
            do {
                let user = try await UserCache.shared.getUser(
                    id: studentId,
                    service: firestoreService,
                    forceRefresh: forceRefresh
                )
                let needsSettings = await MainActor.run { settings == nil }
                async let fetchedPaymentsTask = paymentService
                    .fetchStudentPayments(studentId: studentId)
                async let settingsTask: TeacherSettings? = {
                    guard needsSettings,
                          let teacherId = user.teacherId else { return nil }
                    return try await paymentService
                        .fetchSettings(teacherId: teacherId)
                }()
                let (fetchedPayments,
                     fetchedSettings) = try await (fetchedPaymentsTask,
                                                   settingsTask)
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    let newBalance = user.lessonsBalance ?? 0
                    let previousBalance = savedBalance
                    currentUser = user
                    payments = fetchedPayments
                    if let fetchedSettings { settings = fetchedSettings }
                    isFetching = false
                    onLoading?(false)
                    if forceRefresh && newBalance != previousBalance {
                        onSuccess?("balance_updated".localized)
                    }
                    savedBalance = newBalance
                    onUpdate?()
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
    
    private var savedBalance: Int {
        get { UserDefaults.standard.integer(forKey: UDKeys.studentBalance) }
        set { UserDefaults.standard.set(newValue,
                                        forKey: UDKeys.studentBalance) }
    }
}
