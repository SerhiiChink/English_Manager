//
//  SplashAnimator.swift
//  English Manager
//
//  Created by Sergej Klepikov on 15.05.2026.
//

import UIKit

protocol SplashAnimatorProtocol: AnyObject {
    func animate(logoLabel: UILabel,
                 subtitleLabel: UILabel,
                 arcView: SplashArcView)
}

final class SplashAnimator: SplashAnimatorProtocol {
    func animate(logoLabel: UILabel,
                 subtitleLabel: UILabel,
                 arcView: SplashArcView) {
        arcView.startAnimation()
        UIView.animate(
            withDuration: SplashTextConfig.animDuration,
            delay: SplashTextConfig.titleDelay,
            options: .curveEaseOut
        ) {
            logoLabel.alpha = 1
        }
        UIView.animate(
            withDuration: SplashTextConfig.animDuration,
            delay: SplashTextConfig.subtitleDelay,
            options: .curveEaseOut
        ) {
            subtitleLabel.alpha = 1
            subtitleLabel.transform = .identity
        }
    }
}
