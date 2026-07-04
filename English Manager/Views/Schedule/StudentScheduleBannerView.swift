//
//  StudentScheduleBannerView.swift
//  English Manager
//
//  Created by Sergej Klepikov on 11.04.2026.
//

import UIKit
import SnapKit

final class StudentScheduleBannerView: UIView {
    // MARK: - UI
    private let scheduleStateView = UIView()
    private let schedulesStack = UIStackView()
    private let calendarIcon = UIImageView()
    private let emptyStateView = UIView()
    private let emptyLabel = UILabel()
    private let emptyIcon = UIImageView()
    
    // MARK: - Properties
    private let scheduleFormatter: ScheduleFormatterProtocol = ScheduleFormatter()
    
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
        backgroundColor = .appSurface
        layer.cornerRadius = Layout.cornerRadius
        setupEmptyStateView()
        setupScheduleStateView()
    }
    
    private func setupEmptyStateView() {
        addSubview(emptyStateView)
        emptyStateView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(44).priority(.low)
        }
        emptyIcon.image = UIImage(systemName: "calendar.badge.plus")
        emptyIcon.tintColor = .appTextSecondary
        emptyIcon.contentMode = .scaleAspectFit
        emptyLabel.text = "no_schedule_yet".localized
        emptyLabel.font = .systemFont(ofSize: 13)
        emptyLabel.textColor = .appTextSecondary
        emptyLabel.textAlignment = .center
        emptyStateView.addSubview(emptyIcon)
        emptyStateView.addSubview(emptyLabel)
        emptyIcon.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalTo(emptyLabel.snp.left).offset(-6)
            $0.size.equalTo(18)
        }
        emptyLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    private func setupScheduleStateView() {
        addSubview(scheduleStateView)
        scheduleStateView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        schedulesStack.axis = .vertical
        schedulesStack.spacing = 4
        schedulesStack.alignment = .leading
        scheduleStateView.addSubview(schedulesStack)
        calendarIcon.image = UIImage(systemName: "calendar")
        calendarIcon.tintColor = .appAccent
        calendarIcon.contentMode = .scaleAspectFit
        scheduleStateView.addSubview(calendarIcon)
        calendarIcon.snp.makeConstraints {
            $0.centerY.equalTo(schedulesStack.snp.top).offset(8)
            $0.right.equalToSuperview().inset(12)
            $0.size.equalTo(20)
        }
        schedulesStack.snp.makeConstraints {
            $0.top.left.bottom.equalToSuperview().inset(12)
            $0.right.lessThanOrEqualTo(calendarIcon.snp.left).offset(-8)
        }
        scheduleStateView.isHidden = true
    }

    // MARK: - Configure
    func configure(schedules: [Schedule], timezone: String? = nil) {
        schedulesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let isEmpty = schedules.isEmpty
        emptyStateView.isHidden = !isEmpty
        scheduleStateView.isHidden = isEmpty
        isHidden = false
        guard !isEmpty else { return }
        schedules.forEach { schedule in
            let label = UILabel()
            label.text = scheduleFormatter.formatted(schedule,
                                                     timezone: timezone)
            label.font = .systemFont(ofSize: 13, weight: .medium)
            label.textColor = .appText
            schedulesStack.addArrangedSubview(label)
        }
    }
}

