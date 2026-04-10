//
//  StatItemView.swift
//  English Manager
//
//  Created by Sergej Klepikov on 18.03.2026.
//

import UIKit
import SnapKit

final class StatItemView: UIView {
    // MARK: - UI
    private let valueLabel = UILabel()
    private let titleLabel = UILabel()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - SetupUI
    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [valueLabel, titleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        addSubview(stack)
        stack.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        valueLabel.font = .systemFont(ofSize: 22, weight: .bold)
        valueLabel.textColor = .appText
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.textColor = .appTextSecondary
    }
    
    // MARK: - Configure
    func configure(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
    }
}
