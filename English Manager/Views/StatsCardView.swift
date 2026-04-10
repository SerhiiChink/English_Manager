//
//  StatsCardView.swift
//  English Manager
//
//  Created by Sergej Klepikov on 21.03.2026.
//

import UIKit
import SnapKit

final class StatsCardView: UIView {
    // MARK: - UI
    private let studentsStatsView = StatItemView()
    private let lessonsStatsView = StatItemView()
    
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
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        let divider = UIView()
        divider.backgroundColor = .appBackground
        let stack = UIStackView(arrangedSubviews: [
            studentsStatsView, divider, lessonsStatsView
        ])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        addSubview(stack)
        stack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
            $0.height.equalTo(60)
        }
        divider.snp.makeConstraints {
            $0.width.equalTo(1)
        }
    }
    
    // MARK: - Configure
    func configure(students: Int, lessons: Int) {
        studentsStatsView.configure(title: "Students",
                                    value: "\(students)")
        lessonsStatsView.configure(title: "Lessons",
                                   value: "\(lessons)")
    }
}
