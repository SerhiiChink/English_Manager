//
//  EmptyStateView.swift
//  English Manager
//
//  Created by Sergej Klepikov on 25.05.2026.
//

import UIKit
import SnapKit

final class EmptyStateView: UIView {
    // MARK: - UI
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    
    var onAction: (() -> Void)?
    
    // MARK: - Init
    init(icon: String,
         title: String,
         subtitle: String,
         action: String? = nil,
         onAction: (() -> Void)? = nil) {
        super.init(frame: .zero)
        self.onAction = onAction
        setupUI(icon: icon,
                title: title,
                subtitle: subtitle,
                action: action)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI(icon: String,
                         title: String,
                         subtitle: String,
                         action: String?) {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        addSubview(stack)
        stack.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.left.right.equalToSuperview().inset(32)
        }
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = .appTextSecondary
        iconView.contentMode = .scaleAspectFit
        iconView.snp.makeConstraints {
            $0.width.height.equalTo(56)
        }
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .appText
        titleLabel.textAlignment = .center
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .appTextSecondary
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(subtitleLabel)
        if let action {
            var config = UIButton.Configuration.filled()
            config.title = action
            config.image = UIImage(systemName: "plus.circle.fill")
            config.imagePadding = 6
            config.baseBackgroundColor = .appAccent
            config.baseForegroundColor = .white
            config.cornerStyle = .fixed
            actionButton.configuration = config
            actionButton.layer.cornerRadius = Layout.cornerRadius
            actionButton.addAction(UIAction { [weak self] _ in
                self?.onAction?()
            },for: .touchUpInside)
            stack.setCustomSpacing(24, after: subtitleLabel)
            stack.addArrangedSubview(actionButton)
            actionButton.snp.makeConstraints {
                $0.height.equalTo(Layout.buttonHeight)
                $0.left.right.equalToSuperview()
            }
        }
    }
}
