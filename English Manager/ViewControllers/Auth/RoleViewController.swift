//
//  RoleViewController.swift
//  English Manager
//
//  Created by Sergej Klepikov on 06.03.2026.
//

import UIKit
import SnapKit

final class RoleViewController: UIViewController {
    // MARK: - UI
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let teacherButton = UIButton(type: .system)
    private let studentButton = UIButton(type: .system)
    private let backButton = UIButton(type: .system)
    
    // MARK: - Properties
    private let router: AuthRouterProtocol
    
    // MARK: - Init
    init(
        router: AuthRouterProtocol
    ) {
        self.router = router
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
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .appBackground
        setupIconImageView()
        setupTitleLabel()
        setupTeacherButton()
        setupStudentButton()
        setupBackButton()
    }
    
    private func setupIconImageView() {
        let config = UIImage.SymbolConfiguration(pointSize: 52, weight: .light)
        iconImageView.image = UIImage(systemName: "person.2.fill",
                                      withConfiguration: config)
        iconImageView.tintColor = .Splash.title
        iconImageView.contentMode = .scaleAspectFit
        view.addSubview(iconImageView)
        iconImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(60)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(64)
        }
    }
    
    private func setupTitleLabel() {
        titleLabel.text = "choose_your_role".localized
        titleLabel.font = .systemFont(
            ofSize: SplashTextConfig.titleFontSize,
            weight: .semibold
        )
        titleLabel.textColor = .Splash.title
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func setupTeacherButton() {
        styleRoleButton(teacherButton, title: "teacher".localized)
        teacherButton.addTarget(self,
                                action: #selector(teacherButtonTapped),
                                for: .touchUpInside)
        view.addSubview(teacherButton)
        teacherButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(48)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.height.equalTo(Layout.buttonHeight)
        }
    }
    
    private func setupStudentButton() {
        styleRoleButton(studentButton, title: "student".localized)
        studentButton.addTarget(self,
                                action: #selector(studentButtonTapped),
                                for: .touchUpInside)
        view.addSubview(studentButton)
        studentButton.snp.makeConstraints {
            $0.top.equalTo(teacherButton.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.height.equalTo(Layout.buttonHeight)
        }
    }
    
    private func setupBackButton() {
        backButton.setTitle("back_to_login".localized, for: .normal)
        backButton.setTitleColor(.appTextSecondary, for: .normal)
        backButton.titleLabel?.font = .systemFont(ofSize: 14)
        backButton.addTarget(self,
                             action: #selector(backTapped),
                             for: .touchUpInside)
        view.addSubview(backButton)
        backButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.centerX.equalToSuperview()
        }
    }
    
    // MARK: - Private
    private func styleRoleButton(_ button: UIButton,
                                   title: String) {
        var config = UIButton.Configuration.plain()
        config.title = title
        config.imagePadding = 8
        config.baseForegroundColor = .Splash.title
        config.attributedTitle = AttributedString(title, attributes: .init([
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
        ]))
        button.configuration = config
        button.backgroundColor = UIColor.appSurface.withAlphaComponent(0.8)
        button.layer.cornerRadius = Layout.cornerRadius
    }
    
    // MARK: - Actions
    @objc private func teacherButtonTapped() {
        router.showRoleConfirmation(role: .teacher)
    }
    
    @objc private func studentButtonTapped() {
        router.showRoleConfirmation(role: .student)
    }
    
    @objc private func backTapped() {
        router.showLogin()
    }
}

