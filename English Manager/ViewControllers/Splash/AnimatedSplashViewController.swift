//
//  AnimatedSplashViewController.swift
//  English Manager
//
//  Created by Sergej Klepikov on 15.05.2026.
//

import UIKit
import SnapKit

final class AnimatedSplashViewController: UIViewController {
    // MARK: - UI
    private let arcView = SplashArcView()
    private let logoLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let startButton = UIButton(type: .system)
    
    // MARK: - Properties
    private let router: AuthRouterProtocol
    private let viewModel: AnimatedSplashViewModelProtocol
    private let animator: SplashAnimatorProtocol = SplashAnimator()
    
    // MARK: - Init
    init(
        router: AuthRouterProtocol,
        viewModel: AnimatedSplashViewModelProtocol
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animator.animate(logoLabel: logoLabel,
                         subtitleLabel: subtitleLabel,
                         arcView: arcView)
        viewModel.start()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .Splash.background
        setupArcView()
        setupTextStack()
        setupStartButton()
    }
    
    private func setupArcView() {
        view.addSubview(arcView)
        arcView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupTextStack() {
        logoLabel.text = "english_manager".localized
        logoLabel.font = .systemFont(ofSize: SplashTextConfig.titleFontSize,
                                     weight: .semibold)
        logoLabel.textColor = .Splash.title
        logoLabel.textAlignment = .center
        logoLabel.alpha = 0
        subtitleLabel.text = "learning_system".localized
        subtitleLabel.font = .monospacedSystemFont(
            ofSize: SplashTextConfig.subtitleFontSize,
            weight: .regular
        )
        subtitleLabel.textColor = .Splash.subtitle
        subtitleLabel.textAlignment = .center
        subtitleLabel.alpha = 0
        subtitleLabel.transform = CGAffineTransform(
            translationX: 0,
            y: SplashTextConfig.subtitleSlide
        )
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
    
    private func setupStartButton() {
        startButton.setTitle("get_started".localized, for: .normal)
        startButton.setTitleColor(.Splash.title, for: .normal)
        startButton.titleLabel?.font = .systemFont(ofSize: 17,
                                                   weight: .semibold)
        startButton.backgroundColor = UIColor.Splash.title.withAlphaComponent(0.1)
        startButton.layer.cornerRadius = Layout.cornerRadius
        startButton.alpha = 0
        startButton.addTarget(self,
                              action: #selector(startTapped),
                              for: .touchUpInside)
        view.addSubview(startButton)
        startButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(32)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.height.equalTo(Layout.buttonHeight)
        }
    }
    
    // MARK: - Private    
    private func showStartButtonAnimated() {
        UIView.animate(withDuration: 0.4) {
            self.startButton.alpha = 1
        }
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        viewModel.onReadyToStart = { [weak self] in
            self?.showStartButtonAnimated()
        }
        viewModel.onFinish = { [weak self] role in
            self?.router.showMainScreen(role: role)
        }
    }
    
    // MARK: - Actions
    @objc private func startTapped() {
        viewModel.startTapped()
    }
}
