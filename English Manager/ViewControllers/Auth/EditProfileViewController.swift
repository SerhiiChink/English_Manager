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
    private let saveButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView()
    
    // MARK: - Properties
    private var viewModel: EditProfileViewModelProtocol
    private var pendingAvatarImage: UIImage?
    
    // MARK: - Init
    init(user: User) {
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
        setupSaveButton()
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
            self?.pendingAvatarImage = image
        }
        avatarView.showBadge(true)
    }
    
    private func setupNameField() {
        styleTextField(nameField, placeholder: "first_name".localized)
        view.addSubview(nameField)
        nameField.snp.makeConstraints {
            $0.top.equalTo(avatarView.snp.bottom).offset(24)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.height.equalTo(Layout.buttonHeight)
        }
    }
    
    private func setupSurNameField() {
        styleTextField(surnameField, placeholder: "last_name".localized)
        view.addSubview(surnameField)
        surnameField.snp.makeConstraints {
            $0.top.equalTo(nameField.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.height.equalTo(Layout.buttonHeight)
        }
    }
    
    private func setupSaveButton() {
        saveButton.setTitle("save".localized, for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        saveButton.backgroundColor = .Brand.surfaceFill
        saveButton.layer.cornerRadius = Layout.cornerRadius
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        view.addSubview(saveButton)
        saveButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
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
        title = "edit_profile".localized
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
    
    private func styleTextField(_ field: UITextField,
                                placeholder: String) {
        field.placeholder = placeholder
        field.borderStyle = .none
        field.backgroundColor = .appSurface
        field.layer.cornerRadius = Layout.cornerRadius
        field.textColor = .appText
        field.font = .systemFont(ofSize: 16)
        field.autocorrectionType = .no
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftView = padding
        field.leftViewMode = .always
    }
    
    // MARK: - Actions
    @objc private func saveTapped() {
        if let image = pendingAvatarImage {
            viewModel.uploadAvatar(image)
        }
        viewModel.save(
            name: nameField.text ?? "",
            surname: surnameField.text ?? ""
        )
    }
}
