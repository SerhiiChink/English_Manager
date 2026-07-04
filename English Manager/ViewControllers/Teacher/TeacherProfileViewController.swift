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
    private let contentView = ProfileView()
    private let statsCard = StatsCardView()
    
    // MARK: - Properties
    private let router: TeacherRouterProtocol
    private var viewModel: TeacherProfileViewModelProtocol
    
    // MARK: - Init
    init(
        router: TeacherRouterProtocol,
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
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupCallbacks()
        bindViewModel()
        contentView.build(statsView: statsCard)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchProfile()
    }
    
    // MARK: - SetupUI
    private func setupNavigationBar() {
        setupProfileNavigationBar()
    }
    
    // MARK: - Callbacks
    private func setupCallbacks() {
        contentView.onEdit = { [weak self] in
            guard let user = self?.viewModel.user else { return }
            self?.router.showEditProfile(user: user)
        }
        contentView.onChangePassword = { [weak self] in
            self?.showChangePasswordAlert { password in
                self?.viewModel.changePassword(password)
            }
        }
        contentView.onSignOut = { [weak self] in
            self?.showSignOutAlert {
                self?.viewModel.signOut()
                self?.router.showLogin()
            }
        }
        contentView.onRefresh = { [weak self] in
            self?.viewModel.refresh()
        }
        contentView.onDeleteAccount = { [weak self] in
            guard let self else { return }
            if viewModel.isGoogleUser {
                viewModel.deleteAccountWithGoogle(presenting: self)
            } else if viewModel.isAppleUser {
                guard let window = view.window else { return }
                viewModel.deleteAccountWithApple(window: window)
            } else {
                showDeleteAccountAlert { email, password in
                    self.viewModel.deleteAccount(email: email,
                                                 password: password)
                }
            }
        }
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            guard let self else { return }
            contentView.endRefreshing()
            if let user = viewModel.user {
                contentView.configure(user: user)
            }
            statsCard.configure(items: viewModel.statItems)
        }
        viewModel.onError = { [weak self] message in
            self?.contentView.endRefreshing()
            self?.showAlert(title: "Error", message: message)
        }
        viewModel.onAccountDeleted = { [weak self] in
            self?.router.showLogin()
        }
    }
}
