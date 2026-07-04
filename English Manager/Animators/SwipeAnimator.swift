//
//  SwipeAnimator.swift
//  English Manager
//
//  Created by Sergej Klepikov on 18.04.2026.
//

import UIKit

protocol SwipeAnimatorProtocol {
    func swipeLeft(on view: UIView, completion: @escaping () -> Void)
    func snapBack(_ view: UIView)
}

final class SwipeAnimator: SwipeAnimatorProtocol {
    func swipeLeft(on view: UIView, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.1) {
            view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        } completion: { _ in
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: [.curveEaseIn]) {
                view.transform = CGAffineTransform(
                    translationX: -(view.frame.width + 100),
                    y: 0
                )
                view.alpha = 0
            } completion: { _ in
                completion()
            }
        }
    }
    
    func snapBack(_ view: UIView) {
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseOut) {
            view.transform = .identity
            view.alpha = 1
        }
    }
}
