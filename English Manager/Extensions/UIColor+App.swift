//
//  UIColor+App.swift
//  English Manager
//
//  Created by Sergej Klepikov on 04.03.2026.
//

import UIKit

extension UIColor {
    // MARK: - Background
    static let appBackground: UIColor = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(hex: "#1C1C1E")
            : Brand.background
    }
    
    static let appSurface: UIColor = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(hex: "#2C2C2E")
            : .white
    }

    // MARK: - Text
    static let appText: UIColor = .label
    static let appTextSecondary: UIColor = .secondaryLabel

    // MARK: - Accent
    static let appAccent: UIColor = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(hex: "#C8A97A")
            : Brand.surfaceFill
    }

    // MARK: - Status
    static let appGreen: UIColor = .systemGreen
    static let appRed: UIColor = .systemRed
    static let appGold: UIColor = .systemYellow
    static let appOrange: UIColor = .systemOrange
    static let appBlue: UIColor = .systemBlue
    
    // MARK: - Brand
    enum Brand {
        static let accent: UIColor = UIColor(hex: "#E8C9A7")
        static let background: UIColor = UIColor(hex: "#F0E9DC")
        static let primary: UIColor = UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? .white
                : UIColor(hex: "#2A1E14")
        }
        static let secondary: UIColor = UIColor(hex: "#9A7E5E")
        static let surface: UIColor = UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(hex: "#3A3A3C")
                : UIColor(hex: "#E0D0BC")
        }
        static let surfaceFill: UIColor = UIColor(hex: "#7A6448")
        static let shadow: UIColor = UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(hex: "#000000")
                : UIColor(hex: "#7A6448")
        }
    }

    // MARK: - Splash
    enum Splash {
        static var background: UIColor { .appBackground }
        static var title: UIColor { .appText }
        static var subtitle: UIColor { .appTextSecondary }
        static var loaderTrack: UIColor { Brand.surface }
        static var loaderFill: UIColor { .appAccent }
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
