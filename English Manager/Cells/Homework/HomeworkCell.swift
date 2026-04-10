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
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let feedbackLabel = UILabel()
    private let dateLabel = UILabel()
    private let statusBadge = UIView()
    private let statusLabel = UILabel()
    private let studentNameLabel = UILabel()
    
    // MARK: - Properties
    private let formatter: HomeworkFormatterProtocol = HomeworkFormatter()
    
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
        containerView.backgroundColor = .appSurface
        containerView.layer.cornerRadius = Layout.cornerRadius
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 8
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(4)
        }
        setupStatusBadge()
        setupDateLabel()
        setupStudentNameLabel()
        setupTitleLabel()
        setupDescriptionLabel()
        setupFeedbackLabel()
    }
    
    private func setupStatusBadge() {
        statusBadge.layer.cornerRadius = 8
        containerView.addSubview(statusBadge)
        statusBadge.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.right.equalToSuperview().inset(16)
            $0.height.equalTo(20)
            $0.width.greaterThanOrEqualTo(60)
        }
        statusLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        statusLabel.textColor = .white
        statusBadge.addSubview(statusLabel)
        statusLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.right.equalToSuperview().inset(8)
        }
    }
    
    private func setupDateLabel() {
        dateLabel.font = .systemFont(ofSize: 11)
        dateLabel.textColor = .appTextSecondary
        containerView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints {
            $0.centerY.equalTo(statusBadge)
            $0.left.equalToSuperview().offset(16)
        }
    }
    
    private func setupStudentNameLabel() {
        studentNameLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        studentNameLabel.textColor = .appAccent
        studentNameLabel.isHidden = true
        containerView.addSubview(studentNameLabel)
        studentNameLabel.snp.makeConstraints {
            $0.top.equalTo(statusBadge.snp.bottom).offset(8)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().inset(16)
        }
    }
    
    private func setupTitleLabel() {
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .appText
        titleLabel.numberOfLines = 1
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(studentNameLabel.snp.bottom).offset(2)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().inset(16)
        }
    }
    
    private func setupDescriptionLabel() {
        descriptionLabel.font = .systemFont(ofSize: 13)
        descriptionLabel.textColor = .appTextSecondary
        descriptionLabel.numberOfLines = 2
        containerView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().inset(16)
        }
    }
    
    private func setupFeedbackLabel() {
        feedbackLabel.font = .systemFont(ofSize: 13, weight: .medium)
        feedbackLabel.textColor = .appGreen
        feedbackLabel.numberOfLines = 2
        feedbackLabel.isHidden = true
        containerView.addSubview(feedbackLabel)
        feedbackLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(6)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
    
    // MARK: - Configure
    func configure(with homework: Homework, showStudent: Bool = false) {
        dateLabel.text = formatter.createdDateString(homework)
        titleLabel.text = homework.title
        descriptionLabel.text = homework.description.isEmpty
            ? "No description"
            : homework.description
        studentNameLabel.isHidden = !showStudent
        studentNameLabel.text = homework.studentName
        if let feedback = homework.teacherFeedback,
           !feedback.isEmpty,
           homework.status != .pending {
            feedbackLabel.text = "💬 \(feedback)"
            feedbackLabel.isHidden = false
        } else {
            feedbackLabel.isHidden = true
        }
        switch homework.status {
        case .pending:
            statusBadge.backgroundColor = .appGold
            statusLabel.text = "Pending"
        case .reviewed:
            statusBadge.backgroundColor = .appGreen
            statusLabel.text = homework.grade.map { "Grade: \($0)/10" } ?? "Reviewed"
        case .seen:
            statusBadge.backgroundColor = .appTextSecondary
            statusLabel.text = homework.grade.map { "Grade: \($0)/10" } ?? "Seen"
        }
    }
}
