//
//  SplashArcView.swift
//  English Manager
//
//  Created by Sergej Klepikov on 14.05.2026.
//

import UIKit

final class SplashArcView: UIView {
    // MARK: - Properties
    private var arcLayers: [CAShapeLayer] = []
    private var pendingAnimation = false
    private var isStaticMode = false
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
        buildLayers()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0 else { return }
        updatePaths()
        if pendingAnimation {
            pendingAnimation = false
            runAnimation()
        }
        if isStaticMode {
            showStaticState()
        }
    }
    
    // MARK: - Public
    func startAnimation() {
        guard arcLayers.first?.path != nil else {
            pendingAnimation = true
            return
        }
        runAnimation()
    }
    
    func showStaticState() {
        isStaticMode = true
        arcLayers.forEach { layer in
            layer.removeAllAnimations()
            layer.strokeEnd = 1
        }
    }
    
    // MARK: - Private
    private func buildLayers() {
        for i in 0 ..< SplashArcConfig.radii.count {
            let shape = CAShapeLayer()
            shape.fillColor = UIColor.clear.cgColor
            shape.strokeColor = UIColor.Splash.arcColors[safe: i]?.cgColor ?? UIColor.Splash.arcColors.last?.cgColor
            shape.lineCap = .round
            shape.strokeEnd = 0
            layer.addSublayer(shape)
            arcLayers.append(shape)
        }
    }
    
    private func updatePaths() {
        let scale = min(bounds.width / SplashArcConfig.designWidth,
                        bounds.height / SplashArcConfig.designHeight)
        let widthScale = bounds.width / SplashArcConfig.designWidth
        let cy = SplashArcConfig.designCY * (bounds.height / SplashArcConfig.designHeight)
        for (i, shapeLayer) in arcLayers.enumerated() {
            let path = UIBezierPath(
                arcCenter: CGPoint(x: 0, y: cy),
                radius: SplashArcConfig.radii[i] * scale * 1.05,
                startAngle: -.pi / 2,
                endAngle: .pi / 2,
                clockwise: true
            )
            shapeLayer.path = path.cgPath
            shapeLayer.lineWidth = SplashArcConfig.baseWidths[i] * widthScale
        }
    }
    
    private func runAnimation() {
        arcLayers.forEach { $0.removeAllAnimations() }

        for (i, shapeLayer) in arcLayers.enumerated() {
            shapeLayer.strokeEnd = 0

            let anim = CABasicAnimation(keyPath: "strokeEnd")
            anim.fromValue = 0
            anim.toValue = 1
            anim.duration = SplashArcConfig.durations[i]
            anim.beginTime = CACurrentMediaTime() + SplashArcConfig.delays[i]
            anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            anim.fillMode = .forwards
            anim.isRemovedOnCompletion = false
            shapeLayer.add(anim, forKey: "draw_\(i)")
        }
    }
}
