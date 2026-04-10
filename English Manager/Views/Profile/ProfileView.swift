//
//  ProfileView.swift
//  English Manager
//
//  Created by Sergej Klepikov on 21.03.2026.
//

import UIKit
import SnapKit

final class ProfileView: UIView {
    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let profileCard = UIView()
    private let avatarImageView = AvatarView()
    private let fullNameLabel = UILabel()
    private let emailLabel = UILabel()
    private let editButton = UIButton(type: .system)
    private let changePasswordButton = UIButton(type: .system)
    private let signOutButton = UIButton(type: .system)
    
    // MARK: - Callbacks
    var onEdit: (() -> Void)?
    var onChangePassword: (() -> Void)?
    var onSignOut: (() -> Void)?
    var onRefresh: (() -> Void)?
    
    // MARK: - Additional view
    private var additionalView: UIView?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        backgroundColor = .appBackground
        setupScrollView()
        setupProfileCard()
        setupButtons()
        setupButtonsStack(below: profileCard)
    }
    
    private func setupScrollView() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.addRefreshControl(target: self, action: #selector(refreshTapped))
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
    
    private func setupButtonsStack(below anchor: UIView) {
        let stack = UIStackView(arrangedSubviews: [
            editButton,
            changePasswordButton,
            signOutButton
        ])
        stack.axis = .vertical
        stack.spacing = 12
        contentView.addSubview(stack)
        stack.snp.makeConstraints {
            $0.top.equalTo(anchor.snp.bottom).offset(24)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.bottom.equalToSuperview().inset(24)
        }
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
    
    // MARK: - Configure
    func configure(user: User) {
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
    }
    
    func setAdditionalView(_ view: UIView) {
        additionalView = view
        contentView.addSubview(view)
        view.snp.makeConstraints {
            $0.top.equalTo(profileCard.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(Layout.padding)
        }
        setupButtonsStack(below: view)
    }

    func endRefreshing() {
        scrollView.endRefreshing()
    }
    
    // MARK: - Actions
    @objc private func editTapped() { onEdit?() }
    @objc private func changePasswordTapped() { onChangePassword?() }
    @objc private func signOutTapped() { onSignOut?() }
    @objc private func refreshTapped() { onRefresh?() }
}
