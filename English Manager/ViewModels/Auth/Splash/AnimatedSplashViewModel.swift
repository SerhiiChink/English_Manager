//
//  AnimatedSplashViewModel.swift
//  English Manager
//
//  Created by Sergej Klepikov on 15.05.2026.
//

import Foundation

protocol AnimatedSplashViewModelProtocol: AnyObject {
    var onReadyToStart: (() -> Void)? { get set }
    var onFinish: ((UserRole) -> Void)? { get set }
    func start()
    func startTapped()
}

final class AnimatedSplashViewModel: AnimatedSplashViewModelProtocol {
    // MARK: - Callbacks
    var onReadyToStart: (() -> Void)?
    var onFinish: ((UserRole) -> Void)?
    private let role: UserRole
    
    // MARK: - Properties
    private let delay: TimeInterval
    
    // MARK: - Init
    init(role: UserRole, delay: TimeInterval = 2.4) {
        self.role = role
        self.delay = delay
    }
    
    // MARK: - Animated
    func start() {
        DispatchQueue.main.asyncAfter(
            deadline: .now() + delay
        ) { [weak self] in
            self?.onReadyToStart?()
        }
    }
    
    func startTapped() {
        onFinish?(role)
    }
}
