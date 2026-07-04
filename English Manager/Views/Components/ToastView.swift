//
//  ToastView.swift
//  English Manager
//
//  Created by Sergej Klepikov on 06.05.2026.
//

import UIKit
import SnapKit

private enum ToastStyleMapper {
    static func color(for type: ToastType) -> UIColor {
        switch type {
        case .success:
            return .appGreen
        case .error:
            return .appRed
        case .warning:
            return .appGold
        }
    }
}

enum ToastDuration {
    static let short: TimeInterval = 2.5
    static let long: TimeInterval = 5.0
}

final class ToastView: UIView {
    // MARK: - UI
    private let iconView = UIImageView()
    private let messageLabel = UILabel()
    
    // MARK: - Init
    private init(type: ToastType) {
        super.init(frame: .zero)
        setupUI(type: type)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI(type: ToastType) {
        backgroundColor = ToastStyleMapper.color(for: type)
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        iconView.image = UIImage(systemName: type.icon)
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        addSubview(iconView)
        iconView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }
        messageLabel.text = type.message
        messageLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 2
        addSubview(messageLabel)
        messageLabel.snp.makeConstraints {
            $0.left.equalTo(iconView.snp.right).offset(10)
            $0.right.equalToSuperview().inset(16)
            $0.top.bottom.equalToSuperview().inset(14)
        }
    }
    
    // MARK: - Show
    static func show(_ type: ToastType, in view: UIView, duration: TimeInterval = 2.5) {
        let toast = ToastView(type: type)
        let animator: SlideAnimatorProtocol = SlideAnimator()
        view.addSubview(toast)
        toast.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            $0.left.right.equalToSuperview().inset(16)
        }
        animator.slideIn(toast) {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                animator.slideOut(toast) {
                    toast.removeFromSuperview()
                }
            }
        }
    }
}
