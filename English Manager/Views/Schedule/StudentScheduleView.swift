//
//  StudentScheduleView.swift
//  English Manager
//
//  Created by Sergej Klepikov on 04.04.2026.
//

import UIKit
import SnapKit

final class StudentScheduleView: UIView {
    // MARK: - UI
    private let titleLabel = UILabel()
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let iconImageView = UIImageView()
    
    // MARK: - Properties
    private let scheduleFormatter: ScheduleFormatterProtocol = ScheduleFormatter()
    
    // MARK: - Data
    private var chips: [StudentChip] = []
    
    // MARK: - Callbacks
    var onStudentTapped: ((User) -> Void)?
    
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
        backgroundColor = .appBackground
        setupTitleLabel()
        setupScrollView()
    }
    
    private func setupTitleLabel() {
        titleLabel.text = "schedule".localized
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .appTextSecondary
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.left.equalToSuperview().inset(Layout.padding)
        }
        iconImageView.image = UIImage(systemName: "calendar")
        iconImageView.tintColor = .appAccent
        iconImageView.contentMode = .scaleAspectFit
        addSubview(iconImageView)
        iconImageView.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.right.equalToSuperview().inset(Layout.padding)
            $0.width.height.equalTo(16)
        }
    }
    
    private func setupScrollView() {
        scrollView.showsHorizontalScrollIndicator = false
        addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().inset(12)
            $0.height.equalTo(110)
        }
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .fill
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(
                top: 0,
                left: Layout.padding,
                bottom: 0,
                right: Layout.padding)
            )
            $0.height.equalToSuperview()
        }
    }
    
    // MARK: - Configure
    func configure(student: [User], schedule: [Schedule]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        chips.removeAll()
        for student in student {
            let studentSchedule = schedule.filter { $0.studentId == student.id }
            let chip = StudentChip(
                student: student,
                hasSchedule: !studentSchedule.isEmpty,
                scheduleString: studentSchedule.map {
                    scheduleFormatter.formatted($0)
                },
                isAutoDebitEnabled: student.isAutoDebitEnabled ?? false
            )
            chips.append(chip)
            let chipView = makeChip(for: chip, index: chips.count - 1)
            stackView.addArrangedSubview(chipView)
        }
    }
    
    // MARK: - Private
    private func makeChip(for chip: StudentChip, index: Int) -> UIView {
        let screenWidth = UIScreen.main.bounds.width
        let cardWidth = screenWidth / 2.7
        
        let container = UIView()
        container.tag = index
        container.backgroundColor = chip.hasSchedule ? .appAccent : .appSurface
        container.layer.cornerRadius = Layout.cornerRadius
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.appAccent.cgColor
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.08
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 6
        container.snp.makeConstraints {
            $0.width.equalTo(cardWidth)
        }
        let dot = UIView()
        dot.backgroundColor = chip.isAutoDebitEnabled ? .appGreen : .appRed
        dot.layer.cornerRadius = 4
        container.addSubview(dot)
        dot.snp.makeConstraints {
            $0.top.left.equalToSuperview().inset(12)
            $0.width.height.equalTo(8)
        }
        
        let nameLabel = UILabel()
        nameLabel.text = chip.student.name.isEmpty
            ? chip.student.email
            : chip.student.name
        nameLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        nameLabel.textColor = chip.hasSchedule ? .white : .appText
        nameLabel.numberOfLines = 1
        nameLabel.lineBreakMode = .byTruncatingTail
        container.addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(dot.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().inset(12)
        }
        
        let scheduleLabel = UILabel()
        if chip.hasSchedule {
            let studentSchedule = chip.scheduleString
            scheduleLabel.text = studentSchedule
                .map { $0 }
                .joined(separator: "\n")
            scheduleLabel.font = .systemFont(ofSize: 11)
            scheduleLabel.textColor = .white.withAlphaComponent(0.85)
            scheduleLabel.numberOfLines = 0
        } else {
            scheduleLabel.text = "add_schedule".localized
            scheduleLabel.font = .systemFont(ofSize: 12, weight: .medium)
            scheduleLabel.textColor = .appAccent
        }
        container.addSubview(scheduleLabel)
        scheduleLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(4)
            $0.left.right.equalToSuperview().inset(12)
            $0.bottom.lessThanOrEqualToSuperview().inset(12)
        }
        
        container.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(chipTapped(_:)))
        container.addGestureRecognizer(tap)
        return container
    }
    
    // MARK: - Action
    @objc private func chipTapped(_ gesture: UITapGestureRecognizer) {
        guard let container = gesture.view,
              let index = stackView.arrangedSubviews.firstIndex(of: container),
              index < chips.count else { return }
        let selectedChip = chips[index]
        onStudentTapped?(selectedChip.student)
    }
}
