//
//  AccentBar.swift
//  English Manager
//
//  Created by Sergej Klepikov on 24.05.2026.
//

import UIKit
import SnapKit

final class AccentBar: UIView {
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 2
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Configure
    func setColor(_ color: UIColor) {
        backgroundColor = color
    }
}
