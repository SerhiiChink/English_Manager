//
//  TeacherProfileViewController.swift
//  English Manager
//
//  Created by Sergej Klepikov on 18.03.2026.
//

import UIKit
import SnapKit

final class TeacherProfileViewController: UIViewController {
    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Profile Card
    private let profileCard = UIView()
    private let avatarImageView = AvatarView()
    private let fullNameLabel = UILabel()
    private let emailLabel = UILabel()
    
    // Stats Card
    private let statsCard = UIView()
    private let studentsStatsView = StatItemView()
    private let lessonsStatsView = StatItemView()
    
    // Buttons
    private let editButton = UIButton(type: .system)
    private let changePasswordButton = UIButton(type: .system)
    private let signOutButton = UIButton(type: .system)
//    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - Properties
    private weak var router: AuthRouterProtocol?
    private var viewModel: TeacherProfileViewModelProtocol
    
    // MARK: - Init
    init(
        router: AuthRouterProtocol?,
        viewModel: TeacherProfileViewModelProtocol = TeacherProfileViewModel()
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
        setupNavigationBar()
        bindViewModel()
        refreshControll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchProfile()
    }
    
    // MARK: - SetupUI
    private func setupUI() {
        view.backgroundColor = .appBackground
        setupScrollView()
        setupProfileCard()
        setupStatsCard()
        setupButtons()
//        setupActivityIndicator()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
    }
    
    private func setupProfileCard() {
        profileCard.backgroundColor = .appSurface
        profileCard.layer.cornerRadius = Layout.cornerRadius
        profileCard.layer.shadowColor = UIColor.black.cgColor
        profileCard.layer.shadowOpacity = 0.08
        profileCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        profileCard.layer.shadowRadius = 8
        contentView.addSubview(profileCard)
        profileCard.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.left.right.equalToSuperview().inset(Layout.padding)
        }
        setupAvatarImageView()
        setupFullNameLabel()
        setupEmailLabel()
    }
    
    private func setupStatsCard() {
        statsCard.backgroundColor = .appSurface
        statsCard.layer.cornerRadius = Layout.cornerRadius
        statsCard.layer.shadowColor = UIColor.black.cgColor
        statsCard.layer.shadowOpacity = 0.08
        statsCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        statsCard.layer.shadowRadius = 8
        contentView.addSubview(statsCard)
        statsCard.snp.makeConstraints {
            $0.top.equalTo(profileCard.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(Layout.padding)
        }
        let divider = UIView()
        divider.backgroundColor = .appBackground
        studentsStatsView.configure(title: "Students", value: "0")
        lessonsStatsView.configure(title: "Lessons", value: "0")
        let stack = UIStackView(arrangedSubviews: [
            studentsStatsView,
            divider,
            lessonsStatsView
        ])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        statsCard.addSubview(stack)
        stack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
            $0.height.equalTo(60)
        }
        divider.snp.makeConstraints {
            $0.width.equalTo(1)
        }
    }
    
    private func setupButtons() {
        setupActionButton(editButton,
                          title: "Edit Profile",
                          icon: "pencil",
                          color: .appAccent)
        setupActionButton(changePasswordButton,
                          title: "Change Password",
                          icon: "lock",
                          color: .appAccent)
        setupActionButton(signOutButton,
                          title: "Sign Out",
                          icon: "rectangle.portrait.and.arrow.right",
                          color: .appRed)
        let stack = UIStackView(arrangedSubviews: [
            editButton,
            changePasswordButton,
            signOutButton
        ])
        stack.axis = .vertical
        stack.spacing = 12
        contentView.addSubview(stack)
        stack.snp.makeConstraints {
            $0.top.equalTo(statsCard.snp.bottom).offset(24)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.bottom.equalToSuperview().inset(24)
        }
        editButton.addTarget(self,
                             action: #selector(editTapped),
                             for: .touchUpInside)
        changePasswordButton.addTarget(self,
                                       action: #selector(changePasswordTapped),
                                       for: .touchUpInside)
        signOutButton.addTarget(self,
                                action: #selector(signOutTapped),
                                for: .touchUpInside)
    }
    
    // MARK: - Setup Profile Card
    private func setupAvatarImageView() {
        profileCard.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(80)
        }
        avatarImageView.showBadge(false)
    }

    private func setupFullNameLabel() {
        fullNameLabel.font = .systemFont(ofSize: 20, weight: .bold)
        fullNameLabel.textColor = .appText
        fullNameLabel.textAlignment = .center
        profileCard.addSubview(fullNameLabel)
        fullNameLabel.snp.makeConstraints {
            $0.top.equalTo(avatarImageView.snp.bottom).offset(12)
            $0.left.right.equalToSuperview().inset(16)
        }
    }
    
    private func setupEmailLabel() {
        emailLabel.font = .systemFont(ofSize: 14)
        emailLabel.textColor = .appTextSecondary
        emailLabel.textAlignment = .center
        profileCard.addSubview(emailLabel)
        emailLabel.snp.makeConstraints {
            $0.top.equalTo(fullNameLabel.snp.bottom).offset(4)
            $0.left.right.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset(-24)
        }
    }
    
//    private func setupActivityIndicator() {
//        activityIndicator.hidesWhenStopped = true
//        view.addSubview(activityIndicator)
//        activityIndicator.snp.makeConstraints {
//            $0.center.equalToSuperview()
//        }
//    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Profile"
        navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Setup Action Button
    private func setupActionButton(_ button: UIButton,
                                   title: String,
                                   icon: String,
                                   color: UIColor) {
        button.backgroundColor = .appSurface
        button.layer.cornerRadius = Layout.cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.05
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        var configure = UIButton.Configuration.plain()
        configure.title = title
        configure.image = UIImage(systemName: icon)
        configure.baseForegroundColor = color
        configure.imagePadding = 8
        configure.contentInsets = NSDirectionalEdgeInsets(
            top: 0, leading: 16, bottom: 0, trailing: 0
        )
        button.configuration = configure
        button.snp.makeConstraints {
            $0.height.equalTo(Layout.buttonHeight)
        }
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            self?.scrollView.endRefreshing()
            self?.updateUI()
        }
        viewModel.onError = { [weak self] message in
            self?.scrollView.endRefreshing()
            self?.showAlert(title: "Error", message: message)
        }
//        viewModel.onLoading = { [weak self] isLoading in
//            isLoading
//                ? self?.activityIndicator.startAnimating()
//                : self?.activityIndicator.stopAnimating()
//        }
    }
    
    // MARK: - Update UI
    private func updateUI() {
        guard let user = viewModel.user else { return }
        avatarImageView.configure(name: user.name,
                                  surname: user.surname,
                                  email: user.email)
        if let photoURL = user.photoURL {
            avatarImageView.loadImage(from: photoURL)
        }
        fullNameLabel.text = user.fullName.isEmpty
            ? "No Name"
            : user.fullName
        emailLabel.text = user.email
        studentsStatsView.configure(title: "Students",
                                    value: "\(viewModel.studentsCount)")
        lessonsStatsView.configure(title: "Lessons",
                                   value: "\(viewModel.lessonsCount)")
    }
    
    // MARK: - Actions
    @objc private func editTapped() {
        guard let user = viewModel.user else { return }
        let vc = EditProfileViewController(user: user,
                                           router: router)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func changePasswordTapped() {
        showChangePasswordAlert()
    }
    
    @objc private func signOutTapped() {
        showSignOutAlert()
    }
    
    @objc private func refreshTapped() {
        viewModel.fetchProfile()
    }
    
    // MARK: - Private
    private func refreshControll() {
        scrollView.addRefreshControl(target: self,
                                     action: #selector(refreshTapped))
    }
}

// MARK: - TeacherProfileViewController+Alerts
extension TeacherProfileViewController {
    private func showChangePasswordAlert() {
        let alert = UIAlertController(title: "Change Password",
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addTextField {
            $0.placeholder = "New Password"
            $0.isSecureTextEntry = true
        }
        alert.addTextField {
            $0.placeholder = "Confirm Password"
            $0.isSecureTextEntry = true
        }
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel))
        alert.addAction(UIAlertAction(title: "Change",
                                      style: .default) { [weak self] _ in
            guard let password = alert.textFields?[0].text,
                  let confirm = alert.textFields?[1].text,
                  !password.isEmpty else { return }
            guard password == confirm else {
                self?.showAlert(title: "Error",
                                message: "Passwords do not match")
                return
            }
            self?.viewModel.changePassword(password)
        })
        present(alert, animated: true)
    }
    
    private func showSignOutAlert() {
        let alert = UIAlertController(title: "Sign Out",
                                      message: "Are you sure?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel))
        alert.addAction(UIAlertAction(title: "Sign Out",
                                      style: .destructive) { [weak self] _ in
            self?.viewModel.signOut()
            self?.router?.showLogin()
        })
        present(alert, animated: true)
    }
}
