//
//  PaymentReviewViewModel.swift
//  English Manager
//
//  Created by Sergej Klepikov on 07.05.2026.
//

import Foundation

protocol PaymentReviewViewModelProtocol: AnyObject {
    var payment: PaymentRequest { get }
    var settings: TeacherSettings? { get }
    var lessonsCount: Int { get }
    var onUpdate: (() -> Void)? { get set }
    var onConfirm: (() -> Void)? { get set }
    var onReject: (() -> Void)? { get set }
    var onEdit: ((Int) -> Void)? { get set }
    func confirmTapped()
    func rejectTapped()
    func editTapped(newCount: Int)
    func updatePayment(_ newPayment: PaymentRequest)
}

final class PaymentReviewViewModel: PaymentReviewViewModelProtocol {
    // MARK: - Data
    private(set) var payment: PaymentRequest
    let settings: TeacherSettings?
    
    // MARK: - Callbacks
    var onUpdate: (() -> Void)?
    var onConfirm: (() -> Void)?
    var onReject: (() -> Void)?
    var onEdit: ((Int) -> Void)?
    
    // MARK: - Computed
    var lessonsCount: Int {
        payment.confirmedLessons ?? payment.lessonsCount
    }
    
    // MARK: - Init
    init(payment: PaymentRequest, settings: TeacherSettings?) {
        self.payment = payment
        self.settings = settings
    }
    
    // MARK: - Actions
    func confirmTapped() {
        onConfirm?()
    }
    
    func rejectTapped() {
        onReject?()
    }
    
    func editTapped(newCount: Int) {
        onEdit?(newCount)
    }
    
    func updatePayment(_ newPayment: PaymentRequest) {
        self.payment = newPayment
        onUpdate?()
    }
}
