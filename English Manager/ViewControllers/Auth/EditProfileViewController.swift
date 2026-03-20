//
//  EditProfileViewController.swift
//  English Manager
//
//  Created by Sergej Klepikov on 19.03.2026.
//

import UIKit
import SnapKit

final class EditProfileViewController: UIViewController {
    // MARK: - UI
    private let avatarView = AvatarView()
    private let imagePicker = ImagePickerService()
    private let nameField = UITextField()
    private let surnameField = UITextField()
    private let activityIndicator = UIActivityIndicatorView()
    
    // MARK: - Properties
    private weak var router: AuthRouterProtocol?
    private var viewModel: EditProfileViewModelProtocol
    
    // MARK: - Init
    init(
        user: User,
        router: AuthRouterProtocol?
    ) {
        self.router = router
        self.viewModel = EditProfileViewModel(user: user)
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
        prefillFields()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .appBackground
        setupAvatarView()
        setupNameField()
        setupSurNameField()
        setupActivityIndicator()
    }
    
    private func setupAvatarView() {
        view.addSubview(avatarView)
        avatarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(80)
        }
        avatarView.onTap = { [weak self] in
            guard let self else { return }
            imagePicker.show(from: self)
        }
        imagePicker.onImagePicked = { [weak self] image in
            self?.avatarView.setImage(image)
            self?.viewModel.uploadAvatar(image)
        }
    }
    
    private func setupNameField() {
        nameField.placeholder = "First name"
        nameField.borderStyle = .roundedRect
        nameField.autocorrectionType = .no
        view.addSubview(nameField)
        nameField.snp.makeConstraints {
            $0.top.equalTo(avatarView.snp.bottom).offset(24)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.height.equalTo(Layout.buttonHeight)
        }
    }
    
    private func setupSurNameField() {
        surnameField.placeholder = "Last name"
        surnameField.borderStyle = .roundedRect
        surnameField.autocorrectionType = .no
        view.addSubview(surnameField)
        surnameField.snp.makeConstraints {
            $0.top.equalTo(nameField.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.height.equalTo(Layout.buttonHeight)
        }
    }
    
    private func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    private func setupNavigationBar() {
        title = "Edit profile"
        navigationItem.rightBarButtonItem = .init(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(saveTapped)
        )
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        viewModel.onSuccess = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        viewModel.onError = { [weak self] message in
            self?.showAlert(title: "Error", message: message)
        }
        viewModel.onLoading = { [weak self] isLoading in
            isLoading
            ? self?.activityIndicator.startAnimating()
            : self?.activityIndicator.stopAnimating()
        }
    }
    
    // MARK: - Private
    private func prefillFields() {
        nameField.text = viewModel.user.name
        surnameField.text = viewModel.user.surname ?? ""
        avatarView.configure(name: viewModel.user.name,
                             surname: viewModel.user.surname,
                             email: viewModel.user.email)
        if let photoURL = viewModel.user.photoURL {
            avatarView.loadImage(from: photoURL)
        }
    }
    
    // MARK: - Actions
    @objc private func saveTapped() {
        viewModel.save(
            name: nameField.text ?? "",
            surname: surnameField.text ?? "")
    }
}
