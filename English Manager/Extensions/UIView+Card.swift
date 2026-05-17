//
//  UIView+Card.swift
//  English Manager
//
//  Created by Sergej Klepikov on 22.04.2026.
//

import UIKit

enum CardStyle {
    case `default`
    case bordered
    case splash
}

extension UIView {
    func styleAsCard(_ style: CardStyle = .default) {
        layer.cornerRadius = Layout.cornerRadius
        switch style {
        case .default:
            backgroundColor = .appSurface
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.08
            layer.shadowOffset = CGSize(width: 0, height: 2)
            layer.shadowRadius = 8
            layer.borderWidth = 0
        case .bordered:
            backgroundColor = .Brand.background
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.08
            layer.shadowOffset = CGSize(width: 0, height: 2)
            layer.shadowRadius = 8
            layer.borderWidth = 1
            layer.borderColor = UIColor.Brand.surface.cgColor
        case .splash:
            backgroundColor = UIColor.Splash.loaderTrack.withAlphaComponent(0.5)
            layer.borderWidth = 1
            layer.borderColor = UIColor.Splash.loaderFill.withAlphaComponent(0.3).cgColor
            layer.shadowOpacity = 0
        }
    }
}
