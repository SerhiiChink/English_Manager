//
//  StudentCell.swift
//  English Manager
//
//  Created by Sergej Klepikov on 16.03.2026.
//

import UIKit
import SnapKit

final class StudentCell: UICollectionViewCell {
    static let reuseId = "StudentCell"
    
    // MARK: - UI
    private let containerView = UIView()
    private let avatarView = AvatarView()
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    
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
        containerView.backgroundColor = .appBackground
        containerView.layer.cornerRadius = Layout.cornerRadius
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 8
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(4)
        }
        setupAvatarView()
        setupNameLabel()
        setupEmailLabel()
    }
    
    private func setupAvatarView() {
        avatarView.showBadge(false)
        containerView.addSubview(avatarView)
        avatarView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(48)
        }
    }
    
    private func setupNameLabel() {
        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = .appText
        containerView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.left.equalTo(avatarView.snp.right).offset(12)
            $0.right.equalToSuperview().inset(16)
        }
    }
    
    private func setupEmailLabel() {
        emailLabel.font = .systemFont(ofSize: 13)
        emailLabel.textColor = .appTextSecondary
        containerView.addSubview(emailLabel)
        emailLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(4)
            $0.left.equalTo(avatarView.snp.right).offset(12)
            $0.right.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(16)
        }
    }
    
    // MARK: - Configure
    func configure(with student: User) {
        let displayName = student.teacherAlias ?? student.name
        nameLabel.text = displayName.isEmpty
            ? student.email
            : displayName
        emailLabel.text = student.email
        avatarView.configure(name: student.name,
                             surname: nil,
                             email: student.email)
        if let photoURL = student.photoURL {
            avatarView.loadImage(from: photoURL)
        }
    }
}
