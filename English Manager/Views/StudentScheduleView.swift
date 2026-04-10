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
        titleLabel.text = "Schedule"
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .appTextSecondary
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.left.equalToSuperview().inset(Layout.padding)
        }
    }
    
    private func setupScrollView() {
        scrollView.showsHorizontalScrollIndicator = false
        addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().inset(12)
            $0.height.equalTo(44)
        }
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
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
                }
            )
            chips.append(chip)
            let chipView = makeChip(for: chip, index: chips.count - 1)
            stackView.addArrangedSubview(chipView)
        }
    }
    
    // MARK: - Private
    private func makeChip(for chip: StudentChip, index: Int) -> UIView {
        let container = UIView()
        container.tag = index
        container.backgroundColor = chip.hasSchedule ? .appAccent : .appSurface
        container.layer.cornerRadius = 16
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.appAccent.cgColor
        
        let dot = UIView()
        dot.backgroundColor = chip.hasSchedule ? .appGreen : .clear
        dot.layer.cornerRadius = 4
        container.addSubview(dot)
        
        let label = UILabel()
        label.text = chip.student.displayName
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = chip.hasSchedule ? .white : .appAccent
        container.addSubview(label)
        if chip.hasSchedule {
            dot.snp.makeConstraints {
                $0.width.height.equalTo(8)
                $0.left.equalToSuperview().offset(10)
                $0.centerY.equalToSuperview()
            }
            label.snp.makeConstraints {
                $0.left.equalTo(dot.snp.right).offset(4)
                $0.right.equalToSuperview().inset(12)
                $0.top.bottom.equalToSuperview().inset(8)
            }
        } else {
            label.snp.makeConstraints {
                $0.center.equalToSuperview()
                $0.left.greaterThanOrEqualToSuperview().offset(12)
                $0.right.lessThanOrEqualToSuperview().inset(12)
                $0.top.bottom.equalToSuperview().inset(8)
            }
        }
        container.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(chipTapped(_ :)))
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
