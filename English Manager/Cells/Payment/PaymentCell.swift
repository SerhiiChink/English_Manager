//
//  PaymentCell.swift
//  English Manager
//
//  Created by Sergej Klepikov on 11.04.2026.
//

import UIKit
import SnapKit

final class PaymentCell: UICollectionViewCell {
    static let reuseId = "PaymentCell"
    
    // MARK: - UI
    private let containerView = UIView()
    private let avatarView = AvatarView()
    private let nameLabel = UILabel()
    private let balanceLabel = UILabel()
    private let accentBar = UIView()
    private let pendingDot = UIView()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.styleAsCard()
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(4)
        }
        setupAvatar()
        setupNameLabel()
        setupBalanceLabel()
        setupPendingDot()
        setupAccentBar()
    }
    
    private func setupAvatar() {
        containerView.addSubview(avatarView)
        avatarView.showBadge(false)
        avatarView.snp.makeConstraints {
            $0.top.left.equalToSuperview().offset(16)
            $0.width.height.equalTo(44)
        }
    }
    
    private func setupNameLabel() {
        nameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        nameLabel.textColor = .appText
        nameLabel.numberOfLines = 1
        containerView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(avatarView).offset(3)
            $0.left.equalTo(avatarView.snp.right).offset(10)
            $0.right.equalToSuperview().inset(24)
        }
    }
    
    private func setupBalanceLabel() {
        balanceLabel.font = .systemFont(ofSize: 13)
        balanceLabel.textColor = .appText
        containerView.addSubview(balanceLabel)
        balanceLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(3)
            $0.left.equalTo(avatarView.snp.right).offset(10)
            $0.right.equalToSuperview().inset(16)
        }
    }
    
    private func setupPendingDot() {
        pendingDot.layer.cornerRadius = 3
        pendingDot.backgroundColor = .appGold
        pendingDot.isHidden = true
        containerView.addSubview(pendingDot)
        pendingDot.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.right.equalToSuperview().inset(10)
            $0.width.height.equalTo(6)
        }
    }
    
    private func setupAccentBar() {
        accentBar.layer.cornerRadius = 2
        containerView.addSubview(accentBar)
        accentBar.snp.makeConstraints {
            $0.top.equalTo(avatarView.snp.bottom).offset(12)
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(4)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
    
    // MARK: - Configure
    func configure(with model: PaymentCellModel) {
        nameLabel.text = model.name
        balanceLabel.text = model.balanceText
        avatarView.configure(name: model.name,
                             surname: nil,
                             email: model.name)
        if let photoURL = model.photoURL {
            avatarView.loadImage(from: photoURL)
        }
        let style = BalanceLevelMapper.style(for: model.balanceLevel)
        accentBar.backgroundColor = style.color
        pendingDot.isHidden = !model.hasPending
    }
}
