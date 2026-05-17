//
//  PaymentFormatter.swift
//  English Manager
//
//  Created by Sergej Klepikov on 12.04.2026.
//

import Foundation

protocol PaymentFormatterProtocol {
    func dateString(_ payment: PaymentRequest) -> String
    func amountString(_ payment: PaymentRequest) -> String
    func cellBalanceText(balance: Int) -> String
    func priceText(settings: TeacherSettings) -> String
    func minLessonsText(settings: TeacherSettings) -> String
    func detailText(_ payment: PaymentRequest) -> String
    func paymentAlertMessage(settings: TeacherSettings) -> String
    func invalidAmountMessage(settings: TeacherSettings) -> String
    func totalReceivedText(amount: Double) -> String
    func totalPaidText(amount: Double) -> String
}

final class PaymentFormatter: PaymentFormatterProtocol {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()
    
    // MARK: - Payment
    func dateString(_ payment: PaymentRequest) -> String {
        PaymentFormatter.dateFormatter.string(from: payment.createdAt)
    }
    
    func amountString(_ payment: PaymentRequest) -> String {
        "\(Int(payment.amount)) UAH"
    }
    
    func cellBalanceText(balance: Int) -> String {
        String(format: NSLocalizedString("lessons_count",
                                         comment: ""), balance)
    }
    
    func priceText(settings: TeacherSettings) -> String {
        "\(Int(settings.lessonPrice)) \(settings.currency)"
    }
    
    func minLessonsText(settings: TeacherSettings) -> String {
        "\(settings.minLessons) \("lessons".localized)"
    }
    
    func detailText(_ payment: PaymentRequest) -> String {
        let status = PaymentStatusMapper.style(for: payment.status)
        let count = payment.confirmedLessons ?? payment.lessonsCount
        return "\(count) \("lessons".localized) · \(status.text)"
    }
    
    func paymentAlertMessage(settings: TeacherSettings) -> String {
        "\("price".localized): \(priceText(settings: settings))/\("lesson".localized)\n\("minimum".localized): \(minLessonsText(settings: settings))"
    }
    
    func invalidAmountMessage(settings: TeacherSettings) -> String {
        "\("minimum_payment".localized): \(minLessonsText(settings: settings))"
    }
    
    func totalReceivedText(amount: Double) -> String {
        "\( "total_received".localized ) \(Int(amount)) UAH"
    }
    
    func totalPaidText(amount: Double) -> String {
        "\("total_paid".localized) \(Int(amount)) UAH"
    }
}
