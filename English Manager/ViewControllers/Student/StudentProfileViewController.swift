//
//  StudentProfileViewController.swift
//  English Manager
//
//  Created by Sergej Klepikov on 21.03.2026.
//

import UIKit
import SnapKit

final class StudentProfileViewController: UIViewController {
    // MARK: - UI
    private let contentView = ProfileView()
    
    // MARK: - Properties
    private let router: StudentRouterProtocol
    private var viewModel: StudentProfileViewModelProtocol
    
    // MARK: - Init
    init(
        router: StudentRouterProtocol,
        viewModel: StudentProfileViewModelProtocol = StudentProfileViewModel()
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchProfile()
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        title = "Profile"
        navigationController?.isNavigationBarHidden = false
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
            self?.viewModel.fetchProfile()
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
        }
        viewModel.onError = { [weak self] message in
            self?.contentView.endRefreshing()
            self?.showAlert(title: "Error", message: message)
        }
    }
}
