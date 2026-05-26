//
//  ScheduleHeaderView.swift
//  English Manager
//
//  Created by Sergej Klepikov on 23.05.2026.
//

import UIKit
import SnapKit

final class ScheduleHeaderView: UICollectionReusableView {
    static let reuseId = "ScheduleHeaderView"
    
    // MARK: - UI
    private let scheduleView = StudentScheduleView()

    // MARK: - Callbacks
    var onStudentTapped: ((User) -> Void)? {
        didSet { scheduleView.onStudentTapped = onStudentTapped }
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(scheduleView)
        scheduleView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    func configure(students: [User], schedules: [Schedule]) {
        scheduleView.configure(student: students, schedule: schedules)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            let converted = scheduleView.convert(point, from: self)
            if let hit = scheduleView.hitTest(converted, with: event) {
                return hit
            }
            return super.hitTest(point, with: event)
        }
}
