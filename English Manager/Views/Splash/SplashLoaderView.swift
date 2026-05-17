//
//  SplashLoaderView.swift
//  English Manager
//
//  Created by Sergej Klepikov on 14.05.2026.
//

import UIKit

final class SplashLoaderView: UIView {
    // MARK: - UI
    private let fillView = UIView()
    
    // MARK: - Properties
    private var isAnimating = false

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        fillView.frame = CGRect(x: 0, y: 0,
                                width: bounds.width,
                                height: bounds.height)
        fillView.transform = CGAffineTransform(scaleX: 0.001, y: 1)
    }
    
    // MARK: - Public
    func startAnimation() {
        guard !isAnimating else { return }
        isAnimating = true
        runCycle()
    }
    
    func stopAnimation() {
        isAnimating = false
        fillView.layer.removeAllAnimations()
        fillView.transform = CGAffineTransform(scaleX: 0.001, y: 1)
    }
    
    // MARK: - Private
    private func setupUI() {
        backgroundColor = .Splash.loaderTrack
        layer.cornerRadius = 1
        fillView.backgroundColor = .Splash.loaderFill
        fillView.layer.cornerRadius = 1
        fillView.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        addSubview(fillView)
    }
    
    private func runCycle() {
        guard isAnimating else { return }
        UIView.animate(
            withDuration: SplashLoaderConfig.fillDuration,
            delay: 0,
            options: .curveEaseInOut
        ) { [weak self] in
            self?.fillView.transform = .identity
        } completion: { [weak self] _ in
            guard let self, self.isAnimating else { return }
            UIView.animate(
                withDuration: SplashLoaderConfig.fillDuration,
                delay: 0,
                options: .curveEaseInOut
            ) { [weak self] in
                guard let self else { return }
                self.fillView.transform = CGAffineTransform(scaleX: 0.001, y: 1)
                    .concatenating(CGAffineTransform(translationX: self.bounds.width, y: 0))
            } completion: { [weak self] _ in
                guard let self, self.isAnimating else { return }
                self.fillView.transform = CGAffineTransform(scaleX: 0.001, y: 1)
                self.runCycle()
            }
        }
    }
}
