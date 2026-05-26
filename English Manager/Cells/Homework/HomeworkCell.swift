//
//  HomeworkCell.swift
//  English Manager
//
//  Created by Sergej Klepikov on 29.03.2026.
//

import UIKit
import SnapKit

final class HomeworkCell: UICollectionViewCell {
    static let reuseId = "HomeworkCell"
    
    // MARK: - UI
    private let containerView = UIView()
    private let accentBar = AccentBar()
    private let nameStack = UIStackView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let feedbackLabel = UILabel()
    private let feedbackIcon = UIImageView()
    private let dateLabel = UILabel()
    private let statusBadge = UIView()
    private let badgeIcon = UIImageView()
    private let statusLabel = UILabel()
    private let studentNameLabel = UILabel()
    private let menuButton = CellMenuButton()
    
    // MARK: - Properties
    
    
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
        setupAccentBar()
        setupStatusBadge()
        setupDateLabel()
        setupNameStack()
        setupDescriptionLabel()
        setupFeedbackLabel()
        setupMenuButton()
    }
    
    private func setupAccentBar() {
        containerView.addSubview(accentBar)
        accentBar.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.left.equalToSuperview().offset(8)
            $0.width.equalTo(4)
        }
    }
    
    private func setupStatusBadge() {
        statusBadge.layer.cornerRadius = 8
        containerView.addSubview(statusBadge)
        statusBadge.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.right.equalToSuperview().inset(16)
            $0.height.equalTo(22)
        }
        badgeIcon.contentMode = .scaleAspectFit
        badgeIcon.tintColor = .white
        statusBadge.addSubview(badgeIcon)
        badgeIcon.snp.makeConstraints {
            $0.left.equalToSuperview().offset(6)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(11)
        }
        statusLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        statusLabel.textColor = .white
        statusBadge.addSubview(statusLabel)
        statusLabel.snp.makeConstraints {
            $0.left.equalTo(badgeIcon.snp.right).offset(4)
            $0.right.equalToSuperview().inset(8)
            $0.top.bottom.equalToSuperview().inset(4)
            $0.centerY.equalToSuperview()
        }
    }
    
    private func setupDateLabel() {
        dateLabel.font = .systemFont(ofSize: 11)
        dateLabel.textColor = .appTextSecondary
        containerView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints {
            $0.centerY.equalTo(statusBadge)
            $0.left.equalToSuperview().offset(20)
        }
    }
    
    private func setupNameStack() {
        nameStack.axis = .vertical
        nameStack.spacing = 2
        nameStack.alignment = .leading
        containerView.addSubview(nameStack)
        nameStack.snp.makeConstraints {
            $0.top.equalTo(statusBadge.snp.bottom).offset(10)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().inset(48)
        }
        studentNameLabel.font = .systemFont(ofSize: 14, weight: .medium)
        studentNameLabel.textColor = .appTextSecondary
        studentNameLabel.isHidden = true
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .appText
        titleLabel.numberOfLines = 2
        nameStack.addArrangedSubview(studentNameLabel)
        nameStack.addArrangedSubview(titleLabel)
    }
    
    private func setupDescriptionLabel() {
        descriptionLabel.font = .systemFont(ofSize: 13)
        descriptionLabel.textColor = .appTextSecondary
        descriptionLabel.numberOfLines = 2
        containerView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(nameStack.snp.bottom).offset(6)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset(-12).priority(.low)
        }
    }
    
    private func setupFeedbackLabel() {
        feedbackIcon.image = UIImage(systemName: "text.bubble.fill")
        feedbackIcon.tintColor = .appGreen
        feedbackIcon.contentMode = .scaleAspectFit
        feedbackIcon.isHidden = true
        containerView.addSubview(feedbackIcon)
        feedbackIcon.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(8)
            $0.left.equalToSuperview().offset(20)
            $0.width.height.equalTo(13)
        }
        feedbackLabel.font = .systemFont(ofSize: 13)
        feedbackLabel.textColor = .appGreen
        feedbackLabel.numberOfLines = 0
        feedbackLabel.isHidden = true
        containerView.addSubview(feedbackLabel)
        feedbackLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(5)
            $0.left.equalTo(feedbackIcon.snp.right).offset(5)
            $0.right.equalToSuperview().inset(48)
            $0.bottom.equalToSuperview().offset(-14)
        }
    }
    
    private func setupMenuButton() {
        containerView.addSubview(menuButton)
        menuButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-4)
            $0.right.equalToSuperview().inset(4)
            $0.width.height.equalTo(36)
        }
    }
    
    // MARK: - Configure
    func configure(with model: HomeworkCellModel) {
        dateLabel.text = model.dateText
        titleLabel.text = model.title
        descriptionLabel.text = model.description
        descriptionLabel.isHidden = model.description == nil
        studentNameLabel.text = model.studentName
        studentNameLabel.isHidden = model.studentName == nil
        if let feedback = model.feedbackText, !feedback.isEmpty {
            feedbackLabel.text = feedback
            feedbackLabel.isHidden = false
            feedbackIcon.isHidden = false
        } else {
            feedbackLabel.isHidden = true
            feedbackIcon.isHidden = true
        }
        let style = model.statusStyle
        statusBadge.backgroundColor = style.badgeColor
        statusLabel.text = style.text
        accentBar.setColor(style.accentColor)
        badgeIcon.image = UIImage(systemName: style.icon)
    }
    
    func setMenuActions(_ actions: [CellMenuAction]) {
        menuButton.configure(actions: actions)
    }
    
    func hideMenu() {
        menuButton.isHidden = true
    }
}
