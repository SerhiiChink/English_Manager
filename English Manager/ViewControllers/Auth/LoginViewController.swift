//
//  LoginViewController.swift
//  English Manager
//
//  Created by Sergej Klepikov on 06.03.2026.
//

import UIKit
import SnapKit

final class LoginViewController: UIViewController {
    // MARK: - UI
    private let logoLabel = UILabel()
    private let segmentedControl = UISegmentedControl(
        items: ["enter".localized,
                "sign_up".localized]
    )
    private let fieldsStack = UIStackView()
    private let emailField = UITextField()
    private let passwordField = UITextField()
    private let nameField = UITextField()
    private let confirmPasswordField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let forgotPasswordButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let errorLabel = UILabel()
    private let dividerLabel = UILabel()
    private let appleButton = UIButton(type: .system)
    private let googleButton = UIButton(type: .system)
    
    // MARK: - Properties
    private let router: AuthRouterProtocol
    private var viewModel: LoginViewModelProtocol
    private var isLogin: Bool = true
    
    // MARK: - Init
    init(
        router: AuthRouterProtocol,
        viewModel: LoginViewModelProtocol = LoginViewModel()
    ) {
        self.router = router
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    // MARK: - setupUI
    private func setupUI() {
        view.backgroundColor = .appBackground
        setupTapGesture()
        setupLogoLabel()
        setupSegmentedControl()
        setupFieldsStack()
        setupEmailField()
        setupNameField()
        setupPasswordField()
        setupConfirmPasswordField()
        setupLoginButton()
        setupForgotPasswordButton()
        setupErrorLabel()
        setupActivityIndicator()
        setupGoogleButton()
        setupAppleButton()
        setupDrivider()
    }
    
    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func setupLogoLabel() {
        logoLabel.text = "english_manager".localized
        logoLabel.font = .systemFont(ofSize: SplashTextConfig.titleFontSize,
                                     weight: .semibold)
        logoLabel.textColor = .Splash.title
        logoLabel.textAlignment = .center
        view.addSubview(logoLabel)
        logoLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(48)
            $0.left.right.equalToSuperview().inset(Layout.padding)
        }
    }
    
    private func setupSegmentedControl() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = UIColor.Splash.loaderTrack
        segmentedControl.selectedSegmentTintColor = .appAccent
        segmentedControl.setTitleTextAttributes(
            [.foregroundColor: UIColor.appTextSecondary],
            for: .normal
        )
        segmentedControl.setTitleTextAttributes(
            [.foregroundColor: UIColor.white],
            for: .selected
        )
        segmentedControl.addTarget(self,
                                   action: #selector(segmentedControlChanged),
                                   for: .valueChanged)
        view.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints {
            $0.top.equalTo(logoLabel.snp.bottom).offset(32)
            $0.left.right.equalToSuperview().inset(Layout.padding)
        }
    }
    
    private func setupFieldsStack() {
        fieldsStack.axis = .vertical
        fieldsStack.spacing = 12
        view.addSubview(fieldsStack)
        fieldsStack.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom).offset(24)
            $0.left.right.equalToSuperview().inset(Layout.padding)
        }
        [emailField, nameField, passwordField, confirmPasswordField].forEach {
            $0.snp.makeConstraints { $0.height.equalTo(Layout.buttonHeight) }
            fieldsStack.addArrangedSubview($0)
        }
    }
    
    private func setupEmailField() {
        styleTextField(emailField, placeholder: "email".localized)
        emailField.keyboardType = .emailAddress
        emailField.autocapitalizationType = .none
        emailField.autocorrectionType = .no
    }
    
    private func setupNameField() {
        styleTextField(nameField, placeholder: "name".localized)
        nameField.autocapitalizationType = .words
        nameField.isHidden = true
    }
    
    private func setupPasswordField() {
        styleTextField(passwordField, placeholder: "password".localized)
        passwordField.isSecureTextEntry = true
    }
    
    private func setupConfirmPasswordField() {
        styleTextField(confirmPasswordField,
                       placeholder: "confirm_password".localized)
        confirmPasswordField.isSecureTextEntry = true
        confirmPasswordField.isHidden = true
    }
    
    private func setupLoginButton() {
        loginButton.setTitle("enter".localized, for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 16,
                                                   weight: .semibold)
        loginButton.backgroundColor = .appAccent
        loginButton.layer.cornerRadius = Layout.cornerRadius
        loginButton.addTarget(self,
                              action: #selector(loginTapped),
                              for: .touchUpInside)
        view.addSubview(loginButton)
        loginButton.snp.makeConstraints {
            $0.top.equalTo(fieldsStack.snp.bottom).offset(24)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.height.equalTo(Layout.buttonHeight)
        }
    }
    
    private func setupForgotPasswordButton() {
        forgotPasswordButton.setTitle("forgot_password".localized,
                                      for: .normal)
        forgotPasswordButton.setTitleColor(.appTextSecondary, for: .normal)
        forgotPasswordButton.titleLabel?.font = .systemFont(ofSize: 14)
        forgotPasswordButton.addTarget(self,
                                       action: #selector(forgotPasswordTapped),
                                       for: .touchUpInside)
        view.addSubview(forgotPasswordButton)
        forgotPasswordButton.snp.makeConstraints {
            $0.top.equalTo(loginButton.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func setupErrorLabel() {
        errorLabel.textColor = .appRed
        errorLabel.font = .systemFont(ofSize: 13)
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        view.addSubview(errorLabel)
        errorLabel.snp.makeConstraints {
            $0.top.equalTo(forgotPasswordButton.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().inset(Layout.padding)
        }
    }
    
    private func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .Splash.title
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints {
            $0.top.equalTo(errorLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func setupDrivider() {
        dividerLabel.text = "or".localized
        dividerLabel.textColor = .Splash.subtitle
        dividerLabel.font = .systemFont(ofSize: 14)
        dividerLabel.textAlignment = .center
        view.addSubview(dividerLabel)
        dividerLabel.snp.makeConstraints {
            $0.bottom.equalTo(appleButton.snp.top).offset(-16)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func setupAppleButton() {
        styleSocialButton(appleButton,
                          title: "sign_up_with_apple".localized,
                          icon: UIImage(systemName: "applelogo"))
        appleButton.addTarget(self,
                              action: #selector(appleTapped),
                              for: .touchUpInside)
        view.addSubview(appleButton)
        appleButton.snp.makeConstraints {
            $0.bottom.equalTo(googleButton.snp.top).offset(-12)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.height.equalTo(Layout.buttonHeight)

        }
    }
    
    private func setupGoogleButton() {
        styleSocialButton(googleButton,
                          title: "sign_up_with_google".localized,
                          icon: UIImage(systemName: "globe"))
        googleButton.addTarget(self,
                               action: #selector(googleTapped),
                               for: .touchUpInside)
        view.addSubview(googleButton)
        googleButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(34)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.height.equalTo(Layout.buttonHeight)
        }
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        viewModel.onSuccess = { [weak self] in
            self?.router.showSplash()
        }
        viewModel.onError = { [weak self] message in
            let userMessage = message.contains("already in use")
                ? "account_exists_login".localized
                : message
            self?.showError(userMessage)
        }
        viewModel.onLoading = { [weak self] isLoading in
            isLoading
            ? self?.activityIndicator.startAnimating()
            : self?.activityIndicator.stopAnimating()
        }
    }
    
    // MARK: - Helper
    private func updateUI() {
        nameField.isHidden = isLogin
        confirmPasswordField.isHidden = isLogin
        forgotPasswordButton.isHidden = !isLogin
        loginButton.setTitle(isLogin
                                ? "login".localized
                                : "sign_up".localized,
                             for: .normal)
        errorLabel.isHidden = true
    }
    
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }
    
    private func styleTextField(_ field: UITextField,
                                placeholder: String) {
        field.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.appTextSecondary]
        )
        field.textColor = .Splash.title
        field.font = .systemFont(ofSize: 16)
        field.backgroundColor = UIColor.appSurface.withAlphaComponent(0.8)
        field.layer.cornerRadius = Layout.cornerRadius
        field.borderStyle = .none
        let paddingView = UIView(
            frame: CGRect(x: 0, y: 0, width: 16, height: 0)
        )
        field.leftView = paddingView
        field.leftViewMode = .always
    }
    
    private func styleSocialButton(_ button: UIButton,
                                   title: String,
                                   icon: UIImage?) {
        var config = UIButton.Configuration.plain()
        config.title = title
        config.image = icon?.withTintColor(.Splash.title, renderingMode: .alwaysOriginal)
        config.imagePadding = 8
        config.baseForegroundColor = .Splash.title
        config.attributedTitle = AttributedString(title, attributes: .init([
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
        ]))
        button.configuration = config
        button.backgroundColor = UIColor.appSurface
        button.layer.cornerRadius = Layout.cornerRadius
    }
    
    // MARK: - Actions
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func segmentedControlChanged() {
        isLogin = segmentedControl.selectedSegmentIndex == 0
        updateUI()
    }
    
    @objc private func loginTapped() {
        errorLabel.isHidden = true
        if isLogin {
            viewModel.login(email: emailField.text ?? "",
                            password: passwordField.text ?? "")
        } else {
            guard passwordField.text == confirmPasswordField.text else {
                showError("password_are_not_the_same".localized)
                return
            }
            viewModel.register(email: emailField.text ?? "",
                               password: passwordField.text ?? "",
                               name: nameField.text ?? "")
        }
    }
    
    @objc private func forgotPasswordTapped() {
        viewModel.resetPassword(email: emailField.text ?? "")
    }
    
    @objc private func appleTapped() {
        // Apple sign in
    }
    
    @objc private func googleTapped() {
        viewModel.signInWithGoogle(presenting: self)
    }
}
