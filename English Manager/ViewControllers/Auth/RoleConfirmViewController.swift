//
//  RoleConfirmViewController.swift
//  English Manager
//
//  Created by Sergej Klepikov on 11.05.2026.
//

import UIKit
import SnapKit

final class RoleConfirmViewController: UIViewController {
    // MARK: - UI
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let roleCard = UIView()
    private let roleIconImageView = UIImageView()
    private let roleNameLabel = UILabel()
    private let roleDescriptionLabel = UILabel()
    private let confirmButton = UIButton(type: .system)
    private let changeButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - Properties
    private let router: AuthRouterProtocol
    private let viewModel: RoleConfirmViewModelProtocol
    
    // MARK: - Init
    init(
        router: AuthRouterProtocol,
        viewModel: RoleConfirmViewModelProtocol
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
        configure()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .Splash.background
        setupIconImageView()
        setupTitleLabel()
        setupRoleCard()
        setupConfirmButton()
        setupChangeButton()
        setupActivityIndicator()
    }
    
    private func setupIconImageView() {
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .Splash.title
        view.addSubview(iconImageView)
        iconImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(60)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(64)
        }
    }
    
    private func setupTitleLabel() {
        titleLabel.text = "confirm_role_title".localized
        titleLabel.font = .systemFont(ofSize: SplashTextConfig.titleFontSize,
                                      weight: .semibold)
        titleLabel.textColor = .Splash.title
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(Layout.padding)
        }
    }
    
    private func setupRoleCard() {
        roleCard.styleAsCard(.splash)
        view.addSubview(roleCard)
        roleCard.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(46)
            $0.left.right.equalToSuperview().inset(Layout.padding)
        }
        roleIconImageView.contentMode = .scaleAspectFit
        roleIconImageView.tintColor = .Splash.title
        roleCard.addSubview(roleIconImageView)
        roleIconImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(44)
        }
        roleNameLabel.font = .systemFont(ofSize: 20, weight: .bold)
        roleNameLabel.textColor = .Splash.title
        roleNameLabel.textAlignment = .center
        roleCard.addSubview(roleNameLabel)
        roleNameLabel.snp.makeConstraints {
            $0.top.equalTo(roleIconImageView.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().inset(16)
        }
        roleDescriptionLabel.font = .systemFont(ofSize: 14)
        roleDescriptionLabel.textColor = .Splash.subtitle
        roleDescriptionLabel.textAlignment = .center
        roleDescriptionLabel.numberOfLines = 0
        roleCard.addSubview(roleDescriptionLabel)
        roleDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(roleNameLabel.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset(-24)
        }
    }
    
    private func setupConfirmButton() {
        confirmButton.setTitle("confirm_role_yes".localized, for: .normal)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.titleLabel?.font = .systemFont(ofSize: 16,
                                                     weight: .semibold)
        confirmButton.backgroundColor = .Splash.title
        confirmButton.layer.cornerRadius = Layout.cornerRadius
        confirmButton.addTarget(self,
                                action: #selector(confirmTapped),
                                for: .touchUpInside)
        view.addSubview(confirmButton)
        confirmButton.snp.makeConstraints {
            $0.top.equalTo(roleCard.snp.bottom).offset(32)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.height.equalTo(Layout.buttonHeight)
        }
    }
    
    private func setupChangeButton() {
        changeButton.setTitle("confirm_role_change".localized, for: .normal)
        changeButton.setTitleColor(.Splash.subtitle, for: .normal)
        changeButton.titleLabel?.font = .systemFont(ofSize: 15)
        changeButton.addTarget(self,
                               action: #selector(changeTapped),
                               for: .touchUpInside)
        view.addSubview(changeButton)
        changeButton.snp.makeConstraints {
            $0.top.equalTo(confirmButton.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        viewModel.onSuccess = { [weak self] role in
            guard let self else { return }
            router.showAnimatedSplash(role: role)
        }
        viewModel.onError = { [weak self] message in
            self?.showAlert(title: "Error", message: message)
        }
        viewModel.onLoading = { [weak self] isLoading in
            isLoading
            ? self?.activityIndicator.startAnimating()
            : self?.activityIndicator.stopAnimating()
            self?.confirmButton.isEnabled = !isLoading
        }
    }
    
    // MARK: - Private
    private func configure() {
        let style = viewModel.roleStyle
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 52,
                                                      weight: .light)
        let cardConfig = UIImage.SymbolConfiguration(pointSize: 32,
                                                     weight: .light)
        iconImageView.image = UIImage(systemName: style.icon,
                                      withConfiguration: largeConfig)
        roleIconImageView.image = UIImage(systemName: style.cardIcon,
                                    withConfiguration: cardConfig)
        roleNameLabel.text = style.name
        roleDescriptionLabel.text = style.description
    }
    
    // MARK: - Actions
    @objc private func confirmTapped() {
        viewModel.confirm()
    }
    
    @objc private func changeTapped() {
        navigationController?.popViewController(animated: true)
    }
}
