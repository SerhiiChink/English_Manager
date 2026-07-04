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
    private let teacherBannerView = TeacherBannerView()
    private let editButton = UIButton(type: .system)
    private let changePasswordButton = UIButton(type: .system)
    private let signOutButton = UIButton(type: .system)
    private let deleteAccountButton = UIButton(type: .system)
    
    // MARK: - Callbacks
    var onEdit: (() -> Void)?
    var onChangePassword: (() -> Void)?
    var onSignOut: (() -> Void)?
    var onRefresh: (() -> Void)?
    var onDeleteAccount: (() -> Void)?
    
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
    }
    
    private func setupScrollView() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.addRefreshControl(target: self, action: #selector(refreshTapped))
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
    }
    
    private func setupProfileCard() {
        profileCard.styleAsCard(.bordered)
        contentView.addSubview(profileCard)
        profileCard.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.left.right.equalToSuperview().inset(Layout.padding)
        }
        avatarImageView.showBadge(false)
        profileCard.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(28)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(80)
        }
        fullNameLabel.font = .systemFont(ofSize: 20, weight: .bold)
        fullNameLabel.textColor = .appText
        fullNameLabel.textAlignment = .center
        profileCard.addSubview(fullNameLabel)
        fullNameLabel.snp.makeConstraints {
            $0.top.equalTo(avatarImageView.snp.bottom).offset(12)
            $0.left.right.equalToSuperview().inset(16)
        }
        emailLabel.font = .systemFont(ofSize: 13)
        emailLabel.textColor = .appTextSecondary
        emailLabel.textAlignment = .center
        profileCard.addSubview(emailLabel)
        emailLabel.snp.makeConstraints {
            $0.top.equalTo(fullNameLabel.snp.bottom).offset(4)
            $0.left.right.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(24)
        }
        emailLabel.isUserInteractionEnabled = true
        emailLabel.addGestureRecognizer(UILongPressGestureRecognizer(
            target: self,
            action: #selector(emailLongPressed(_:))
        ))
    }
    
    private func setupButtons() {
        setupActionButton(editButton,
                          title: "edit_profile".localized,
                          icon: "pencil",
                          isDestructive: false)
        setupActionButton(changePasswordButton,
                          title: "change_password".localized,
                          icon: "lock",
                          isDestructive: false)
        setupActionButton(signOutButton,
                          title: "sign_out".localized,
                          icon: "rectangle.portrait.and.arrow.right",
                          isDestructive: true)
        setupActionButton(deleteAccountButton,
                          title: "delete_account".localized,
                          icon: "trash",
                          isDestructive: true)
        editButton.addTarget(self,
                             action: #selector(editTapped),
                             for: .touchUpInside)
        changePasswordButton.addTarget(self,
                                       action: #selector(changePasswordTapped),
                                       for: .touchUpInside)
        signOutButton.addTarget(self,
                                action: #selector(signOutTapped),
                                for: .touchUpInside)
        deleteAccountButton.addTarget(self,
                                      action: #selector(deleteAccountTapped),
                                      for: .touchUpInside)
    }
    
    private func setupActionButton(_ button: UIButton,
                                   title: String,
                                   icon: String,
                                   isDestructive: Bool) {
        let tint: UIColor = isDestructive ? .appRed : .appAccent
        var cfg = UIButton.Configuration.plain()
        cfg.image = UIImage(systemName: icon)
        cfg.imagePadding = 12
        cfg.baseForegroundColor = tint
        cfg.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        var attr = AttributeContainer()
        attr.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        cfg.attributedTitle = AttributedString(title, attributes: attr)
        button.configuration = cfg
        button.contentHorizontalAlignment = .leading
        button.snp.makeConstraints { $0.height.equalTo(Layout.buttonHeight) }
    }
    
    private func groupCard(label text: String,
                           buttons: [UIButton]) -> UIView {
        let wrapper = UIView()
        let sectionLabel = UILabel()
        sectionLabel.text = text.uppercased()
        sectionLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        sectionLabel.textColor = .appTextSecondary
        wrapper.addSubview(sectionLabel)
        sectionLabel.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
        }
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        buttons.enumerated().forEach { index, btn in
            if index > 0 {
                let sep = DividerView(color: .Brand.surface)
                stack.addArrangedSubview(sep)
                sep.snp.makeConstraints {
                    $0.left.right.equalToSuperview().inset(16)
                }
            }
            stack.addArrangedSubview(btn)
        }
        let card = UIView()
        card.styleAsCard(.bordered)
        card.clipsToBounds = true
        card.addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }
        wrapper.addSubview(card)
        card.snp.makeConstraints {
            $0.top.equalTo(sectionLabel.snp.bottom).offset(6)
            $0.left.right.bottom.equalToSuperview()
        }
        return wrapper
    }
    
    // MARK: - Public
    func build(statsView: UIView, showTeacherBanner: Bool = false) {
        contentView.addSubview(statsView)
        statsView.snp.makeConstraints {
            $0.top.equalTo(profileCard.snp.bottom).offset(12)
            $0.left.right.equalToSuperview().inset(Layout.padding)
        }
        if showTeacherBanner {
            contentView.addSubview(teacherBannerView)
            teacherBannerView.snp.makeConstraints {
                $0.top.equalTo(statsView.snp.bottom).offset(12)
                $0.left.right.equalToSuperview().inset(Layout.padding)
            }
            buildBottomStack(below: teacherBannerView)
        } else {
            buildBottomStack(below: statsView)
        }
    }
    
    private func buildBottomStack(below anchor: UIView) {
        let accountCard = groupCard(label: "account".localized,
                                    buttons: [editButton,
                                              changePasswordButton])
        let sessionCard = groupCard(label: "session".localized,
                                    buttons: [signOutButton,
                                              deleteAccountButton])
        let stack = UIStackView(arrangedSubviews: [accountCard, sessionCard])
        stack.axis = .vertical
        stack.spacing = 12
        contentView.addSubview(stack)
        stack.snp.makeConstraints {
            $0.top.equalTo(anchor.snp.bottom).offset(24)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.bottom.equalToSuperview().inset(24)
        }
    }
    
    func configure(user: User) {
        avatarImageView.configure(name: user.name,
                                  surname: user.surname,
                                  email: user.email)
        if let photoURL = user.photoURL {
            avatarImageView.loadImage(from: photoURL)
        }
        fullNameLabel.text = user.fullName.isEmpty
            ? "no_name".localized
            : user.fullName
        emailLabel.text = user.email
    }
    
    func configureTeacher(_ teacher: User?) {
        teacherBannerView.configure(teacher: teacher)
    }
    
    func endRefreshing() {
        scrollView.endRefreshing()
    }
    
    // MARK: - Actions
    @objc private func editTapped() { onEdit?() }
    @objc private func changePasswordTapped() { onChangePassword?() }
    @objc private func signOutTapped() { onSignOut?() }
    @objc private func refreshTapped() { onRefresh?() }
    @objc private func deleteAccountTapped() { onDeleteAccount?() }
    @objc private func emailLongPressed(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        UIPasteboard.general.string = emailLabel.text
        ToastView.show(.success("email_copied".localized), in: self)
    }
}
