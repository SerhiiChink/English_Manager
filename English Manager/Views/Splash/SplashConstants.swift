//
//  SplashConstants.swift
//  English Manager
//
//  Created by Sergej Klepikov on 14.05.2026.
//

import UIKit

// MARK: - Arc
enum SplashArcConfig {
    static let designCY: CGFloat = 140
    static let designWidth: CGFloat = 280
    static let designHeight: CGFloat = 607
    static let radii: [CGFloat] = [225, 185, 145, 110, 75]
    static let baseWidths: [CGFloat] = [1.0, 1.25, 1.6, 2.0, 2.5]
    static let delays: [Double] = [0.0, 0.14, 0.26, 0.38, 0.50]
    static let durations: [Double] = [1.8, 1.8, 1.6, 1.6, 1.4]
}

// MARK: - Text
enum SplashTextConfig {
    static let titleFontSize: CGFloat = 38
    static let subtitleFontSize: CGFloat = 14
    static let titleDelay: Double = 0.85
    static let subtitleDelay: Double = 1.05
    static let animDuration: Double = 0.7
    static let subtitleSlide: CGFloat = 8
    static let stackCenterYOffset: CGFloat = 140
}

// MARK: - Loader
enum SplashLoaderConfig {
    static let width: CGFloat = 44
    static let height: CGFloat = 2
    static let bottomInset: CGFloat = 32
    static let fillDuration: Double = 0.9
}
