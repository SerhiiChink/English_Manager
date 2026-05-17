//
//  DividerView.swift
//  English Manager
//
//  Created by Sergej Klepikov on 04.05.2026.
//

import UIKit
import SnapKit

final class DividerView: UIView {
    init(color: UIColor = .appBackground, height: CGFloat = 1) {
        super .init(frame: .zero)
        backgroundColor = color
        snp.makeConstraints {
            $0.height.equalTo(height)
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
