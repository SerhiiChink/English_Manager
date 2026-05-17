//
//  SlideAnimator.swift
//  English Manager
//
//  Created by Sergej Klepikov on 06.05.2026.
//

import UIKit

protocol SlideAnimatorProtocol {
    func slideIn(_ view: UIView, completion: (() -> Void)?)
    func slideOut(_ view: UIView, completion: (() -> Void)?)
}

final class SlideAnimator: SlideAnimatorProtocol {
    func slideIn(_ view: UIView, completion: (() -> Void)? = nil) {
        view.alpha = 0
        view.transform = CGAffineTransform(translationX: 0, y: -20)
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .curveEaseOut) {
            view.alpha = 1
            view.transform = .identity
        } completion: { _ in
            completion?()
        }
    }
    
    func slideOut(_ view: UIView, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .curveEaseIn) {
            view.alpha = 0
            view.transform = CGAffineTransform(translationX: 0, y: -20)
        } completion: { _ in
            completion?()
        }
    }
}
