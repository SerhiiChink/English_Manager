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
    private let stack = UIStackView()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        styleAsCard(.bordered)
        setupStack()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupStack() {
        stack.axis = .horizontal
        stack.distribution = .fill
        addSubview(stack)
        stack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
            $0.height.equalTo(60)
        }
    }
    
    // MARK: - Configure
    func configure(items: [StatItem]) {
        stack.arrangedSubviews.forEach {
            stack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        var statViews: [StatItemView] = []
        items.enumerated().forEach { index, item in
            let statView = StatItemView()
            statView.configure(title: item.title, value: item.value)
            stack.addArrangedSubview(statView)
            statViews.append(statView)
            if index < items.count - 1 {
                let divider = DividerView(color: .Brand.surface)
                stack.addArrangedSubview(divider)
                divider.snp.makeConstraints { $0.width.equalTo(1) }
            }
        }
        if let first = statViews.first {
            statViews.dropFirst().forEach {
                $0.snp.makeConstraints { $0.width.equalTo(first) }
            }
        }
    }
}
