//
//  PaymentHistoryView.swift
//  English Manager
//
//  Created by Sergej Klepikov on 09.05.2026.
//

import UIKit
import SnapKit

final class PaymentHistoryView: UIView {
    // MARK: - UI
    private let titleLabel = UILabel()
    private let totalLabel = UILabel()
    private let clearButton = UIButton(type: .system)
    private let divider = UIView()
    private let stackView = UIStackView()
    
    // MARK: - Properties
    private let formatter: PaymentFormatterProtocol = PaymentFormatter()
    
    // MARK: - Callbacks
    var onClear: (() -> Void)?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*,unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        styleAsCard()
        setupHeader()
        setupDivider()
        setupStack()
    }
    
    private func setupHeader() {
        titleLabel.text = "payment_history".localized
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .appTextSecondary
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
        }
        clearButton.setImage(UIImage(systemName: "trash"), for: .normal)
        clearButton.tintColor = .appRed
        clearButton.alpha = 0.3
        clearButton.addAction(UIAction { [weak self] _ in
            self?.onClear?()
        }, for: .touchUpInside)
        addSubview(clearButton)
        clearButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.right.equalToSuperview().inset(16)
        }
        totalLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        totalLabel.textColor = .appText
        addSubview(totalLabel)
        totalLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(32)
            $0.left.equalToSuperview().offset(16)
        }
    }
    
    private func setupDivider() {
        divider.backgroundColor = .appBackground
        addSubview(divider)
        divider.snp.makeConstraints {
            $0.top.equalTo(totalLabel.snp.bottom).offset(12)
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(1)
        }
    }
    
    private func setupStack() {
        stackView.axis = .vertical
        stackView.spacing = 0
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-8)
        }
    }
    
    // MARK: - Configure
    func configure(totalText: String, payments: [PaymentRequest]) {
        totalLabel.text = totalText
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard !payments.isEmpty else {
            let empty = UILabel()
            empty.text = "no_history_yet".localized
            empty.font = .systemFont(ofSize: 14)
            empty.textColor = .appTextSecondary
            empty.textAlignment = .center
            stackView.addArrangedSubview(empty)
            empty.snp.makeConstraints { $0.height.equalTo(44) }
            return
        }
        payments.enumerated().forEach { index, payment in
            stackView.addArrangedSubview(makeRow(for: payment))
            if index < payments.count - 1 {
                let separator = UIView()
                separator.backgroundColor = .appBackground
                stackView.addArrangedSubview(separator)
                separator.snp.makeConstraints { $0.height.equalTo(1) }
            }
        }
    }
    
    // MARK: - Private
    private func makeRow(for payment: PaymentRequest) -> UIView {
        let container = UIView()
        let style = PaymentStatusMapper.style(for: payment.status)
        let dot = UIView()
        dot.backgroundColor = style.color
        dot.layer.cornerRadius = 4
        container.addSubview(dot)
        dot.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(8)
        }
        let dateLabel = UILabel()
        dateLabel.text = formatter.dateString(payment)
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .appTextSecondary
        container.addSubview(dateLabel)
        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.left.equalTo(dot.snp.right).offset(10)
        }
        let detailLabel = UILabel()
        detailLabel.text = formatter.detailText(payment)
        detailLabel.font = .systemFont(ofSize: 14, weight: .medium)
        detailLabel.textColor = .appText
        container.addSubview(detailLabel)
        detailLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(2)
            $0.left.equalTo(dot.snp.right).offset(10)
            $0.bottom.equalToSuperview().offset(-12)
        }
        let amountLabel = UILabel()
        amountLabel.text = formatter.amountString(payment)
        amountLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        amountLabel.textColor = style.color
        container.addSubview(amountLabel)
        amountLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().inset(16)
        }
        return container
    }
}
