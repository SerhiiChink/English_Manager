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
    private let segmentedControl = UISegmentedControl(items: ["Enter",
                                                              "Sign Up"])
    private let emailField = UITextField()
    private let passwordField = UITextField()
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
        setupEmailField()
        setupPasswordField()
        setupConfirmPasswordField()
        setupLoginButton()
        setupForgotPasswordButton()
        setupErrorLabel()
        setupActivityIndicator()
        setupDrivider()
        setupAppleButton()
        setupGoogleButton()
    }
    
    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func setupLogoLabel() {
        logoLabel.text = "English Manager"/// localization
        logoLabel.font = .systemFont(ofSize: 32, weight: .bold)
        logoLabel.textColor = .appText
        logoLabel.textAlignment = .center
        view.addSubview(logoLabel)
        logoLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(48)
            $0.left.right.equalToSuperview().inset(Layout.padding)
        }
    }
    
    private func setupSegmentedControl() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self,
                                   action: #selector(segmentedControlChanged),
                                   for: .valueChanged)
        view.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints {
            $0.top.equalTo(logoLabel.snp.bottom).offset(32)
            $0.left.right.equalToSuperview().inset(Layout.padding)
        }
    }
    
    private func setupEmailField() {
        emailField.placeholder = "Email" /// lokalization
        emailField.keyboardType = .emailAddress
        emailField.autocapitalizationType = .none
        emailField.autocorrectionType = .no
        emailField.borderStyle = .roundedRect
        view.addSubview(emailField)
        emailField.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom).offset(24)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.height.equalTo(Layout.buttonHeight)
        }
    }
    
    private func setupPasswordField() {
        passwordField.placeholder = "Password"/// lokalization
        passwordField.isSecureTextEntry = true
        passwordField.borderStyle = .roundedRect
        view.addSubview(passwordField)
        passwordField.snp.makeConstraints {
            $0.top.equalTo(emailField.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.height.equalTo(Layout.buttonHeight)
        }
    }
    
    private func setupConfirmPasswordField() {
        confirmPasswordField.placeholder = "Confirm password"//localiz
        confirmPasswordField.isSecureTextEntry = true
        confirmPasswordField.borderStyle = .roundedRect
        confirmPasswordField.isHidden = true
        view.addSubview(confirmPasswordField)
        confirmPasswordField.snp.makeConstraints {
            $0.top.equalTo(passwordField.snp.bottom).offset(12)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.height.equalTo(Layout.buttonHeight)
        }
    }
    
    private func setupLoginButton() {
        loginButton.setTitle("Enter", for: .normal)/// lokalization
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.backgroundColor = .appAccent
        loginButton.layer.cornerRadius = Layout.cornerRadius
        loginButton.addTarget(self,
                              action: #selector(loginTapped),
                              for: .touchUpInside)
        view.addSubview(loginButton)
        loginButton.snp.makeConstraints {
            $0.top.equalTo(confirmPasswordField.snp.bottom).offset(24)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.height.equalTo(Layout.buttonHeight)
        }
    }
    
    private func setupForgotPasswordButton() {
        forgotPasswordButton.setTitle("Forgot password?", for: .normal)//localiz
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
    
    private func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints {
            $0.top.equalTo(errorLabel.snp.bottom).offset(16)
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
    
    private func setupDrivider() {
        dividerLabel.text = "or"// localiz
        dividerLabel.textColor = .appTextSecondary
        dividerLabel.font = .systemFont(ofSize: 14)
        dividerLabel.textAlignment = .center
        view.addSubview(dividerLabel)
        dividerLabel.snp.makeConstraints {
            $0.top.equalTo(activityIndicator.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func setupAppleButton() {
        appleButton.setTitle("Continue with Apple", for: .normal)// localiz
        appleButton.setTitleColor(.appText, for: .normal)
        appleButton.setImage(UIImage(systemName: "applelogo"), for: .normal)
        appleButton.tintColor = .appText
        appleButton.backgroundColor = .appSurface
        appleButton.layer.cornerRadius = Layout.cornerRadius
        appleButton.addTarget(self,
                              action: #selector(appleTapped),
                              for: .touchUpInside)
        view.addSubview(appleButton)
        appleButton.snp.makeConstraints {
            $0.top.equalTo(dividerLabel.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.height.equalTo(Layout.buttonHeight)
        }
    }
    
    private func setupGoogleButton() {
        googleButton.setTitle("Continue with Google", for: .normal)//localiz
        googleButton.setTitleColor(.appText, for: .normal)
        googleButton.backgroundColor = .appSurface
        googleButton.tintColor = .appText
        googleButton.layer.cornerRadius = Layout.cornerRadius
        googleButton.addTarget(self,
                               action: #selector(googleTapped),
                               for: .touchUpInside)
        view.addSubview(googleButton)
        googleButton.snp.makeConstraints {
            $0.top.equalTo(appleButton.snp.bottom).offset(12)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.height.equalTo(Layout.buttonHeight)
        }
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        viewModel.onSuccess = { [weak self] in
            self?.router.showRole()
        }
        viewModel.onError = { [weak self] message in
            self?.showError(message)
        }
        viewModel.onLoading = { [weak self] isLoading in
            isLoading
            ? self?.activityIndicator.startAnimating()
            : self?.activityIndicator.stopAnimating()
        }
    }
    
    // MARK: - Helper
    private func updateUI() {
        confirmPasswordField.isHidden = isLogin
        forgotPasswordButton.isHidden = !isLogin
        loginButton.setTitle(isLogin ? "Login" : "Sign Up",
                             for: .normal)
        errorLabel.isHidden = true
    }
    
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
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
                showError("Password are not the same")
                return
            }
            viewModel.register(email: emailField.text ?? "",
                               password: passwordField.text ?? "")
        }
    }
    
    @objc private func forgotPasswordTapped() {
        viewModel.resetPassword(email: emailField.text ?? "")
    }
    
    @objc private func appleTapped() {
        // Apple sign in
    }
    
    @objc private func googleTapped() {
        // Google sign in
    }
}
