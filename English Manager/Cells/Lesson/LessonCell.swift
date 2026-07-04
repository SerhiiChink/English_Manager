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
    private let accentBar = AccentBar()
    private let dateLabel = UILabel()
    private let studentNameLabel = UILabel()
    private let topicLabel = UILabel()
    private let bookLabel = UILabel()
    private let menuButton = CellMenuButton()
    
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
        containerView.styleAsCard()
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(4)
        }
        setupAccentBar()
        setupDateLabel()
        setupStudentNameLabel()
        setupTopicLabel()
        setupBookLabel()
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
    
    private func setupDateLabel() {
        dateLabel.font = .systemFont(ofSize: 12, weight: .medium)
        dateLabel.textColor = .appTextSecondary
        containerView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-16)
        }
    }
    
    private func setupStudentNameLabel() {
        studentNameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        studentNameLabel.textColor = .appText
        containerView.addSubview(studentNameLabel)
        studentNameLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(4)
            $0.left.equalToSuperview().offset(20)
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
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-16)
        }
    }
    
    private func setupBookLabel() {
        bookLabel.font = .systemFont(ofSize: 12)
        bookLabel.textColor = .appTextSecondary
        containerView.addSubview(bookLabel)
        bookLabel.snp.makeConstraints {
            $0.top.equalTo(topicLabel.snp.bottom).offset(6)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
    
    private func setupMenuButton() {
        containerView.addSubview(menuButton)
        menuButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.right.equalToSuperview().inset(4)
            $0.width.height.equalTo(36)
        }
    }
    
    // MARK: - Configure
    func configure(with lesson: Lesson) {
        dateLabel.text = formatter.lessonDateString(for: lesson)
        studentNameLabel.text = lesson.studentName
        topicLabel.text = lesson.topic
        bookLabel.text = lesson.bookTitle
        accentBar.setColor(OccurrenceStatusMapper.accentColor(for: lesson))
    }
    
    func setMenuActions(_ actions: [CellMenuAction]) {
        menuButton.configure(actions: actions)
    }
    
    func hideMenu() {
        menuButton.isHidden = true
    }
}
