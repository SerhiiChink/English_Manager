//
//  LessonCell.swift
//  English Manager
//
//  Created by Sergej Klepikov on 14.03.2026.
//

import UIKit
import SnapKit

final class LessonCell: UICollectionViewCell {
    static let reuseId = "LessonCell"
    
    // MARK: - UI
    private let containerView = UIView()
    private let dateLabel = UILabel()
    private let studentNameLabel = UILabel()
    private let topicLabel = UILabel()
    private let bookLabel = UILabel()
    
    // MARK: - Properties
    private let formatter: LessonFormatterProtocol = LessonFormatter()
    
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
        setupDateLabel()
        setupStudentNameLabel()
        setupTopicLabel()
        setupBookLabel()
    }
    
    private func setupDateLabel() {
        dateLabel.font = .systemFont(ofSize: 12, weight: .medium)
        dateLabel.textColor = .appTextSecondary
        containerView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
        }
    }
    
    private func setupStudentNameLabel() {
        studentNameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        studentNameLabel.textColor = .appText
        containerView.addSubview(studentNameLabel)
        studentNameLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(4)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
        }
    }
    
    private func setupTopicLabel() {
        topicLabel.font = .systemFont(ofSize: 15)
        topicLabel.textColor = .appText
        topicLabel.numberOfLines = 2
        containerView.addSubview(topicLabel)
        topicLabel.snp.makeConstraints {
            $0.top.equalTo(studentNameLabel.snp.bottom).offset(6)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
        }
    }
    
    private func setupBookLabel() {
        bookLabel.font = .systemFont(ofSize: 12)
        bookLabel.textColor = .appTextSecondary
        containerView.addSubview(bookLabel)
        bookLabel.snp.makeConstraints {
            $0.top.equalTo(topicLabel.snp.bottom).offset(6)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
    
    // MARK: - Configure
    func configure(with lesson: Lesson) {
        dateLabel.text = formatter.lessonDateString(for: lesson)
        studentNameLabel.text = lesson.studentName
        topicLabel.text = lesson.topic
        bookLabel.text = lesson.bookTitle
    }
}
