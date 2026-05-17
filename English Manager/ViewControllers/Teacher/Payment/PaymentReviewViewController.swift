//
//  PaymentReviewViewController.swift
//  English Manager
//
//  Created by Sergej Klepikov on 06.05.2026.
//

import UIKit
import SnapKit

final class PaymentReviewViewController: UIViewController {
    // MARK: - UI
    private let titleLabel = UILabel()
    private let divider = DividerView()
    private let infoCard = UIView()
    private let lessonsCountLabel = UILabel()
    private let amountLabel = UILabel()
    private let dateLabel = UILabel()
    private let confirmButton = UIButton()
    private let editButton = UIButton()
    private let rejectButton = UIButton()
    
    // MARK: - Properties
    private let viewModel: PaymentReviewViewModelProtocol
    private let formatter: PaymentFormatterProtocol = PaymentFormatter()
    
    // MARK: - Init
    init(viewModel: PaymentReviewViewModelProtocol) {
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
        configure()
        bindViewModel()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .appSurface
        setupTitle()
        setupInfoCard()
        setupButtons()
    }
    
    private func setupTitle() {
        titleLabel.text = "review_payment".localized
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .appText
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
        }
        view.addSubview(divider)
        divider.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.left.right.equalToSuperview()
        }
    }
    
    private func setupInfoCard() {
        infoCard.backgroundColor = .appBackground
        infoCard.layer.cornerRadius = Layout.cornerRadius
        view.addSubview(infoCard)
        infoCard.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(Layout.padding)
        }
        let lessonsTitle = UILabel()
        lessonsTitle.text = "lessons_capitalized".localized
        lessonsTitle.font = .systemFont(ofSize: 14)
        lessonsTitle.textColor = .appTextSecondary
        infoCard.addSubview(lessonsTitle)
        lessonsTitle.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.left.equalToSuperview().offset(16)
        }
        lessonsCountLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        lessonsCountLabel.textColor = .appText
        infoCard.addSubview(lessonsCountLabel)
        lessonsCountLabel.snp.makeConstraints {
            $0.centerY.equalTo(lessonsTitle)
            $0.right.equalToSuperview().inset(16)
        }
        
        let separator = DividerView()
        infoCard.addSubview(separator)
        separator.snp.makeConstraints {
            $0.top.equalTo(lessonsTitle.snp.bottom).offset(12)
            $0.left.right.equalToSuperview().inset(16)
        }
        let amountTitle = UILabel()
        amountTitle.text = "amount".localized
        amountTitle.font = .systemFont(ofSize: 14)
        amountTitle.textColor = .appTextSecondary
        infoCard.addSubview(amountTitle)
        amountTitle.snp.makeConstraints {
            $0.top.equalTo(separator.snp.bottom).offset(12)
            $0.left.equalToSuperview().offset(16)
        }
        amountLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        amountLabel.textColor = .appAccent
        infoCard.addSubview(amountLabel)
        amountLabel.snp.makeConstraints {
            $0.centerY.equalTo(amountTitle)
            $0.right.equalToSuperview().inset(16)
        }
        let separatorAmount = DividerView()
        infoCard.addSubview(separatorAmount)
        separatorAmount.snp.makeConstraints {
            $0.top.equalTo(amountTitle.snp.bottom).offset(12)
            $0.left.right.equalToSuperview().inset(16)
        }
        let dateTitle = UILabel()
        dateTitle.text = "date".localized
        dateTitle.font = .systemFont(ofSize: 14)
        dateTitle.textColor = .appTextSecondary
        infoCard.addSubview(dateTitle)
        dateTitle.snp.makeConstraints {
            $0.top.equalTo(separatorAmount.snp.bottom).offset(12)
            $0.left.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-14)
        }
        dateLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        dateLabel.textColor = .appText
        infoCard.addSubview(dateLabel)
        dateLabel.snp.makeConstraints {
            $0.centerY.equalTo(dateTitle)
            $0.right.equalToSuperview().inset(16)
        }
    }
    
    private func setupButtons() {
        var confirmConfig = UIButton.Configuration.filled()
        confirmConfig.title = "confirm".localized
        confirmConfig.image = UIImage(systemName: "checkmark.circle.fill")
        confirmConfig.imagePadding = 6
        confirmConfig.baseBackgroundColor = .appGreen
        confirmButton.configuration = confirmConfig
        confirmButton.layer.cornerRadius = Layout.cornerRadius
        confirmButton.addAction(UIAction { [weak self] _ in
            self?.dismiss(animated: true) {
                self?.viewModel.confirmTapped()
            }
        }, for: .touchUpInside)
        editButton.configuration = makeConfig(title: "edit".localized,
                                              icon: "pencil",
                                              color: .appAccent)
        editButton.layer.cornerRadius = 10
        editButton.addAction(UIAction { [weak self] _ in
            self?.showEditSheet()
        }, for: .touchUpInside)
        rejectButton.configuration = makeConfig(title: "reject".localized,
                                                icon: "xmark",
                                                color: .appRed)
        rejectButton.layer.cornerRadius = 10
        rejectButton.addAction(UIAction { [weak self] _ in
            self?.showRejectConfirmation()
        }, for: .touchUpInside)
        let secondaryStack = UIStackView()
        secondaryStack.axis = .horizontal
        secondaryStack.spacing = 12
        secondaryStack.distribution = .fillEqually
        view.addSubview(secondaryStack)
        view.addSubview(confirmButton)
        secondaryStack.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.height.equalTo(44)
        }
        confirmButton.snp.makeConstraints {
            $0.bottom.equalTo(secondaryStack.snp.top).offset(-12)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.height.equalTo(Layout.buttonHeight)
        }
        secondaryStack.addArrangedSubview(editButton)
        secondaryStack.addArrangedSubview(rejectButton)
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            self?.configure()
        }
    }
    
    // MARK: - Configure
    private func configure() {
        lessonsCountLabel.text = "\(viewModel.lessonsCount)"
        amountLabel.text = formatter.amountString(viewModel.payment)
        dateLabel.text = formatter.dateString(viewModel.payment)
    }
    
    // MARK: - Private
    private func makeConfig(title: String, icon: String, color: UIColor) -> UIButton.Configuration {
        var config = UIButton.Configuration.tinted()
        config.imagePadding = 4
        config.baseBackgroundColor = color
        config.baseForegroundColor = color
        config.preferredSymbolConfigurationForImage = .init(pointSize: 12)
        var attr = AttributeContainer()
        attr.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        config.attributedTitle = AttributedString(title, attributes: attr)
        config.image = UIImage(systemName: icon)
        return config
    }
    
    // MARK: - Actions
    private func showEditSheet() {
        guard let settings = viewModel.settings else { return }
        let alert = UIAlertController(
            title: "edit_payment".localized,
            message: "\("price".localized): \(formatter.priceText(settings: settings))/\("lesson".localized)",
            preferredStyle: .alert
        )
        alert.addTextField {
            $0.keyboardType = .numberPad
            $0.text = "\(self.viewModel.lessonsCount)"
        }
        alert.addAction(UIAlertAction(title: "cancel".localized,
                                      style: .cancel))
        alert.addAction(UIAlertAction(
            title: "save".localized,
            style: .default) { [weak self] _ in
                guard let text = alert.textFields?[0].text,
                      let newCount = Int(text),
                      newCount > 0 else { return }
                self?.viewModel.editTapped(newCount: newCount)
            }
        )
        present(alert, animated: true)
    }
    
    private func showRejectConfirmation() {
        let alert = UIAlertController(
            title: "reject_payment?".localized,
            message: "this_action_cannot_be_undone".localized,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "cancel".localized,
                                      style: .cancel))
        alert.addAction(UIAlertAction(
            title: "reject".localized,
            style: .destructive) { [weak self] _ in
                self?.dismiss(animated: true) {
                    self?.viewModel.rejectTapped()
                }
            }
        )
        present(alert, animated: true)
    }
}
