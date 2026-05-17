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
    private let backgroundImageView = UIImageView()
    private let logoLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    // MARK: - Properties
    private let router: AuthRouterProtocol
    private let viewModel: SplashViewModelProtocol
    
    // MARK: - Init
    init(
        router: AuthRouterProtocol,
        viewModel: SplashViewModelProtocol
    ) {
        self.router = router
        self.viewModel = viewModel
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
        bindViewModel()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .Splash.background
        setupBackground()
        setupTextStack()
    }
    
    private func setupBackground() {
        backgroundImageView.image = UIImage(named: "splash_background")
        backgroundImageView.contentMode = .scaleAspectFill
        view.addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupTextStack() {
        logoLabel.text = "english_manager".localized
        logoLabel.font = .systemFont(ofSize: SplashTextConfig.titleFontSize,
                                     weight: .semibold)
        logoLabel.textColor = .Splash.title
        logoLabel.textAlignment = .center
        logoLabel.alpha = 1
        subtitleLabel.text = "learning_system".localized
        subtitleLabel.font = .monospacedSystemFont(
            ofSize: SplashTextConfig.subtitleFontSize,
            weight: .regular
        )
        subtitleLabel.textColor = .Splash.subtitle
        subtitleLabel.textAlignment = .center
        subtitleLabel.alpha = 1
        let stack = UIStackView(arrangedSubviews: [logoLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        view.addSubview(stack)
        stack.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(SplashTextConfig.stackCenterYOffset)
        }
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        viewModel.onShowMain = { [weak self] role in
            self?.router.showMainScreen(role: role)
        }
        viewModel.onShowRole = { [weak self] in
            self?.router.showRole()
        }
        viewModel.onShowLogin = { [weak self] in
            self?.router.showLogin()
        }
        viewModel.resolve()
    }
}
