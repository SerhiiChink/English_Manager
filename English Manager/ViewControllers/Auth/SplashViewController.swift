//
//  SplashViewController.swift
//  English Manager
//
//  Created by Sergej Klepikov on 06.03.2026.
//

import UIKit
import SnapKit

final class SplashViewController: UIViewController {
    // MARK: - UI
    private let logoLabel = UILabel()
    private let indicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - Properties
    private let router: AuthRouterProtocol
    private let authService: AuthServiceProtocol
    
    // MARK: - Init
    init(
        router: AuthRouterProtocol,
        authService: AuthServiceProtocol
    ) {
        self.router = router
        self.authService = authService
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup UI
    private func setupLogoLabel() {
        logoLabel.text = "English Manager"
        logoLabel.textColor = .appText
        logoLabel.font = .systemFont(ofSize: 40, weight: .bold)
        logoLabel.textAlignment = .center
        view.addSubview(logoLabel)
        logoLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    private func setupIndicator() {
        indicator.hidesWhenStopped = true
        view.addSubview(indicator)
        indicator.snp.makeConstraints {
            $0.top.equalTo(logoLabel.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
        }
    }
    
    // MARK: - Helper
    private func setupUI() {
        view.backgroundColor = .appBackground
        setupLogoLabel()
        setupIndicator()
        checkAuth()
    }
    
    // MARK: - Auth Check
    private func checkAuth() {
        indicator.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self else { return }
            if self.authService.isLoggedIn {
                if let roleString = UserDefaults.standard.string(
                    forKey: UDKeys.userRole
                ), let role = UserRole(rawValue: roleString) {
                    self.router.showMainScreen(role: role)
                } else {
                    self.router.showRole()
                }
            } else {
                self.router.showLogin()
            }
        }
    }
}
