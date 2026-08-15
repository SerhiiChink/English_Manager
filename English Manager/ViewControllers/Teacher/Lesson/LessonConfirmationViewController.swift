//
//  LessonConfirmationViewController.swift
//  English Manager
//
//  Created by Sergej Klepikov on 26.07.2026.
//

import UIKit
import SnapKit

final class LessonConfirmationViewController: UIViewController {
    // MARK: - UI
    private let avatarView = AvatarView()
    private let nameLabel = UILabel()
    private let dateLabel = UILabel()
    private let divider = DividerView()
    private let missedButton = UIButton(type: .system)
    private let cancelledButton = UIButton(type: .system)
    private let chargeButton = UIButton(type: .system)
    
    // MARK: - Properties
    private let viewModel: LessonConfirmationViewModelProtocol
    private let formatter: LessonFormatterProtocol = LessonFormatter()
    
    // MARK: - Init
    init(viewModel: LessonConfirmationViewModelProtocol) {
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
        bindViewModel()
        configure()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .appSurface
        setupHeader()
        setupDivider()
        setupStudentSection()
        setupChargeButton()
        setupSmallButtons()
    }
    
    private func setupHeader() {
        let calendarIcon = UIImageView()
        calendarIcon.image = UIImage(systemName: "calendar.badge.clock")
        calendarIcon.tintColor = .appAccent
        calendarIcon.contentMode = .scaleAspectFit
        view.addSubview(calendarIcon)
        calendarIcon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.left.equalToSuperview().inset(Layout.padding)
            $0.width.height.equalTo(22)
        }
        dateLabel.font = .systemFont(ofSize: 15, weight: .medium)
        dateLabel.textColor = .appText
        dateLabel.textAlignment = .right
        view.addSubview(dateLabel)
        dateLabel.snp.makeConstraints {
            $0.centerY.equalTo(calendarIcon)
            $0.right.equalToSuperview().inset(Layout.padding)
            $0.left.equalTo(calendarIcon.snp.right).offset(8)
        }
    }
    
    private func setupDivider() {
        view.addSubview(divider)
        divider.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(Layout.padding)
        }
    }
    
    private func setupStudentSection() {
        let questionLabel = UILabel()
        questionLabel.text = "how_was_the_lesson".localized
        questionLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        questionLabel.textColor = .appText
        questionLabel.textAlignment = .center
        view.addSubview(questionLabel)
        questionLabel.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom).offset(40)
            $0.left.right.equalToSuperview().inset(Layout.padding)
        }
        avatarView.showBadge(false)
        view.addSubview(avatarView)
        avatarView.snp.makeConstraints {
            $0.top.equalTo(questionLabel.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(80)
        }
        nameLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        nameLabel.textColor = .appText
        nameLabel.textAlignment = .center
        view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(avatarView.snp.bottom).offset(12)
            $0.left.right.equalToSuperview().inset(Layout.padding)
        }
    }
    
    private func setupSmallButtons() {
        missedButton.configuration = makeSmallConfig(
            title: "student_missed".localized,
            icon: "person.fill.xmark",
            color: .appOrange
        )
        missedButton.addAction(UIAction { [weak self] _ in
            self?.dismiss(animated: true) {
                self?.viewModel.missedLesson()
            }
        }, for: .touchUpInside)
        
        cancelledButton.configuration = makeSmallConfig(
            title: "lesson_cancelled".localized,
            icon: "xmark.circle",
            color: .appRed
        )
        cancelledButton.addAction(UIAction { [weak self] _ in
            self?.showCancelOptions()
        }, for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [
            missedButton, cancelledButton
        ])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        view.addSubview(stack)
        stack.snp.makeConstraints {
            $0.bottom.equalTo(chargeButton.snp.top).offset(-12)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.height.equalTo(44)
        }
    }
    
    private func setupChargeButton() {
        var config = UIButton.Configuration.filled()
        config.title = "charge_the_lesson".localized
        config.image = UIImage(systemName: "checkmark.circle.fill")
        config.imagePadding = 8
        config.baseBackgroundColor = .appGreen
        config.baseForegroundColor = .white
        config.cornerStyle = .fixed
        chargeButton.configuration = config
        chargeButton.layer.cornerRadius = Layout.cornerRadius
        chargeButton.addAction(UIAction { [weak self] _ in
            self?.dismiss(animated: true) {
                self?.viewModel.chargeLesson()
            }
        }, for: .touchUpInside)
        view.addSubview(chargeButton)
        chargeButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.height.equalTo(Layout.buttonHeight)
        }
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        viewModel.onDismiss = { [weak self] in
            self?.dismiss(animated: true)
        }
        viewModel.onError = { [weak self] message in
            self?.showAlert(title: "error".localized, message: message)
        }
    }
    
    // MARK: - Configure
    private func configure() {
        let student = viewModel.student
        avatarView.configure(
            name: student.name,
            surname: student.surname,
            email: student.email
        )
        if let photoURL = student.photoURL {
            avatarView.loadImage(from: photoURL)
        }
        nameLabel.text = student.displayName
        dateLabel.text = formatter.occurrenceDateString(for: viewModel.occurrence.scheduledAt)
        presentationController?.delegate = self
    }
    
    // MARK: - Private
    private func makeSmallConfig(title: String,
                                 icon: String,
                                 color: UIColor) -> UIButton.Configuration {
        var config = UIButton.Configuration.tinted()
        config.image = UIImage(systemName: icon)
        config.imagePadding = 6
        config.baseBackgroundColor = color
        config.baseForegroundColor = color
        config.background.cornerRadius = Layout.cornerRadius
        config.cornerStyle = .fixed
        var attributes = AttributeContainer()
        attributes.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        config.attributedTitle = AttributedString(title, attributes: attributes)
        return config
    }
    
    // MARK: - Actions
    private func showCancelOptions() {
        let alert = UIAlertController(
            title: "lesson_cancelled".localized,
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(
            title: "next_date_by_schedule".localized,
            style: .default) { [weak self] _ in
                self?.viewModel.cancelLesson(customDate: nil)
            }
        )
        alert.addAction(UIAlertAction(
            title: "custom_date".localized,
            style: .default) { [weak self] _ in
                self?.showDatePicker()
            }
        )
        alert.addAction(UIAlertAction(title: "cancel".localized,
                                      style: .cancel))
        present(alert, animated: true)
    }
    
    private func showDatePicker() {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .wheels
        picker.minimumDate = Date()
        let alert = UIAlertController(
            title: "select_date".localized,
            message: "\n\n\n\n\n\n\n\n\n",
            preferredStyle: .alert
        )
        alert.view.addSubview(picker)
        picker.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(50)
        }
        alert.addAction(UIAlertAction(title: "cancel".localized,
                                      style: .cancel))
        alert.addAction(UIAlertAction(
            title: "confirm".localized,
            style: .default) { [weak self] _ in
                self?.viewModel.cancelLesson(customDate: picker.date)
            }
        )
        present(alert, animated: true)
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension LessonConfirmationViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        viewModel.onSwipedDown?()
    }
}
