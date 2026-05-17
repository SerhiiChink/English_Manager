//
//  UIColor+App.swift
//  English Manager
//
//  Created by Sergej Klepikov on 04.03.2026.
//

import UIKit

extension UIColor {
    // MARK: - Background
    static let appBackground: UIColor = .systemBackground
    static let appSurface: UIColor = .secondarySystemBackground

    // MARK: - Text
    static let appText: UIColor = .label
    static let appTextSecondary: UIColor = .secondaryLabel

    // MARK: - Accent
    static let appAccent: UIColor = .systemBlue

    // MARK: - Status
    static let appGreen: UIColor = .systemGreen
    static let appRed: UIColor = .systemRed
    static let appGold: UIColor = .systemYellow
    static let appOrange: UIColor = .systemOrange
    
    // MARK: - Brand
    enum Brand {
        static let accent = UIColor(hex: "#E8C9A7")
        static let background: UIColor = UIColor(hex: "#f0e9dc")
        static let primary: UIColor = UIColor(hex: "#2a1e14")
        static let secondary: UIColor = UIColor(hex: "#9a7e5e")
        static let surface: UIColor = UIColor(hex: "#e0d0bc")
        static let surfaceFill: UIColor = UIColor(hex: "#7a6448")
    }

    // MARK: - Splash
    enum Splash {
        static var background: UIColor { Brand.background }
        static var title: UIColor { Brand.primary }
        static var subtitle: UIColor { Brand.secondary }
        static var loaderTrack: UIColor { Brand.surface }
        static var loaderFill: UIColor { Brand.surfaceFill }
        static let arcColors: [UIColor] = [
            UIColor(hex: "#c8b89a").withAlphaComponent(0.7),
            UIColor(hex: "#b8a47e").withAlphaComponent(0.82),
            UIColor(hex: "#9a8462"),
            UIColor(hex: "#7a6244"),
            UIColor(hex: "#5a4230"),
        ]
    }

    // MARK: - Hex initializer
    convenience init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let r = CGFloat((value >> 16) & 0xFF) / 255
        let g = CGFloat((value >> 8) & 0xFF) / 255
        let b = CGFloat(value & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
