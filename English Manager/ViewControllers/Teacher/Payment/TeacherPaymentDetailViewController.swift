//
//  TeacherPaymentDetailViewController.swift
//  English Manager
//
//  Created by Sergej Klepikov on 11.04.2026.
//

import UIKit
import SnapKit

final class TeacherPaymentDetailViewController: UIViewController {
    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let paymentCard = UIView()
    private let statusBadge = UIView()
    private let statusLabel = UILabel()
    private let nameLabel = UILabel()
    private let dateTitleLabel = UILabel()
    private let dateLabel = UILabel()
    private let lastPaymentDivider = DividerView()
    private let balanceTitleLabel = UILabel()
    private let balanceValueLabel = UILabel()
    private let lastPaymentTitle = UILabel()
    private let lessonsTitle = UILabel()
    private let lessonsValue = UILabel()
    private let amountTitle = UILabel()
    private let amountValue = UILabel()
    private let historyView = PaymentHistoryView()
    private let confirmButton = UIButton(type: .custom)
    
    // MARK: - Properties
    private let viewModel: TeacherPaymentDetailViewModelProtocol
    private let router: TeacherRouterProtocol
    private let formatter: PaymentFormatterProtocol = PaymentFormatter()
    
    // MARK: - Init
    init(
        viewModel: TeacherPaymentDetailViewModelProtocol,
        router: TeacherRouterProtocol
    ) {
        self.viewModel = viewModel
        self.router = router
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
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchData()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .appBackground
        setupConfirmButton()
        setupScrollView()
        setupPaymentCard()
        setupHistoryCard()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.addRefreshControl(target: self,
                                     action: #selector(refreshTapped))
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(confirmButton.snp.top).offset(-8)
        }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
    }
    
    private func setupPaymentCard() {
        paymentCard.styleAsCard()
        contentView.addSubview(paymentCard)
        paymentCard.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.left.right.equalToSuperview().inset(Layout.padding)
        }
        setupStatusBadge()
        setupStudentInfo()
        setupLessonsRow()
        setupAmountRow()
    }
    
    private func setupStatusBadge() {
        statusBadge.layer.cornerRadius = 8
        statusLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        statusLabel.textColor = .white
        statusLabel.textAlignment = .center
        statusBadge.addSubview(statusLabel)
        statusLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(4)
            $0.left.right.equalToSuperview().inset(8)
        }
        paymentCard.addSubview(statusBadge)
        statusBadge.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.right.equalToSuperview().inset(16)
        }
    }
    
    private func setupStudentInfo() {
        nameLabel.font = .systemFont(ofSize: 18, weight: .bold)
        nameLabel.textColor = .appText
        paymentCard.addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalTo(statusBadge.snp.left).offset(-8)
        }
        balanceTitleLabel.text = "lessons_paid".localized
        balanceTitleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        balanceTitleLabel.textColor = .appText
        balanceTitleLabel.textAlignment = .left
        paymentCard.addSubview(balanceTitleLabel)
        balanceTitleLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(16)
            $0.left.equalToSuperview().offset(16)
        }
        balanceValueLabel.font = .systemFont(ofSize: 22, weight: .bold)
        balanceValueLabel.textColor = .appAccent
        balanceValueLabel.textAlignment = .right
        paymentCard.addSubview(balanceValueLabel)
        balanceValueLabel.snp.makeConstraints {
            $0.centerY.equalTo(balanceTitleLabel)
            $0.right.equalToSuperview().inset(16)
        }
        paymentCard.addSubview(lastPaymentDivider)
        lastPaymentDivider.snp.makeConstraints {
            $0.top.equalTo(balanceValueLabel.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(16)
        }
    }
    
    private func setupLessonsRow() {
        lastPaymentTitle.text = "last_payment".localized
        lastPaymentTitle.font = .systemFont(ofSize: 14, weight: .semibold)
        lastPaymentTitle.textColor = .appText
        lastPaymentTitle.textAlignment = .center
        paymentCard.addSubview(lastPaymentTitle)
        lastPaymentTitle.snp.makeConstraints {
            $0.top.equalTo(lastPaymentDivider.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
        }
        dateTitleLabel.text = "date".localized
        dateTitleLabel.font = .systemFont(ofSize: 14)
        dateTitleLabel.textColor = .appTextSecondary
        paymentCard.addSubview(dateTitleLabel)
        dateTitleLabel.snp.makeConstraints {
            $0.top.equalTo(lastPaymentTitle.snp.bottom).offset(12)
            $0.left.equalToSuperview().offset(16)
        }
        dateLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        dateLabel.textColor = .appText
        paymentCard.addSubview(dateLabel)
        dateLabel.snp.makeConstraints {
            $0.centerY.equalTo(dateTitleLabel)
            $0.right.equalToSuperview().inset(16)
        }
        lessonsTitle.text = "lessons_capitalized".localized
        lessonsTitle.font = .systemFont(ofSize: 14)
        lessonsTitle.textColor = .appTextSecondary
        lessonsValue.font = .systemFont(ofSize: 14, weight: .semibold)
        lessonsValue.textColor = .appText
        paymentCard.addSubview(lessonsTitle)
        paymentCard.addSubview(lessonsValue)
        lessonsTitle.snp.makeConstraints {
            $0.top.equalTo(dateTitleLabel.snp.bottom).offset(12)
            $0.left.equalToSuperview().offset(16)
        }
        lessonsValue.snp.makeConstraints {
            $0.centerY.equalTo(lessonsTitle)
            $0.right.equalToSuperview().inset(16)
        }
    }
    
    private func setupAmountRow() {
        amountTitle.text = "amount".localized
        amountTitle.font = .systemFont(ofSize: 14)
        amountTitle.textColor = .appTextSecondary
        amountValue.font = .systemFont(ofSize: 14, weight: .semibold)
        amountValue.textColor = .appText
        paymentCard.addSubview(amountTitle)
        paymentCard.addSubview(amountValue)
        amountTitle.snp.makeConstraints {
            $0.top.equalTo(lessonsTitle.snp.bottom).offset(12)
            $0.left.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-16)
        }
        amountValue.snp.makeConstraints {
            $0.centerY.equalTo(amountTitle)
            $0.right.equalToSuperview().inset(16)
        }
    }
    
    private func setupConfirmButton() {
        var config = UIButton.Configuration.filled()
        var attr = AttributeContainer()
        attr.font = .systemFont(ofSize: 16, weight: .semibold)
        config.attributedTitle = AttributedString("verify_payment".localized,
                                                  attributes: attr)
        config.image = UIImage(systemName: "magnifyingglass.circle.fill")
        config.imagePadding = 4
        config.baseBackgroundColor = .Brand.surfaceFill
        config.background.cornerRadius = Layout.cornerRadius
        config.cornerStyle = .fixed
        confirmButton.configuration = config
        confirmButton.addAction(UIAction { [weak self] _ in
            self?.showPaymentReview()
        }, for: .touchUpInside)
        view.addSubview(confirmButton)
        confirmButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.height.equalTo(Layout.buttonHeight)
        }
    }
    
    private func setupHistoryCard() {
        contentView.addSubview(historyView)
        historyView.onClear = { [weak self] in
            self?.showClearHistoryAlert()
        }

        historyView.snp.makeConstraints {
            $0.top.equalTo(paymentCard.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }

    private func setupNavigationBar() {
        title = viewModel.student.displayName
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plusminus"),
            style: .plain,
            target: self,
            action: #selector(adjustBalanceTapped))
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            self?.scrollView.endRefreshing()
            self?.configure()
        }
        viewModel.onSuccess = { [weak self] message in
            guard let self else { return }
            ToastView.show(.success(message),
                           in: view,
                           duration: ToastDuration.short)
        }
        viewModel.onError = { [weak self] message in
            guard let self else { return }
            scrollView.endRefreshing()
            ToastView.show(.error(message),
                           in: view,
                           duration: ToastDuration.short)
        }
        viewModel.onAutoDebitSuggestion = { [weak self] in
            guard let self else { return }
            ToastView.show(.warning("auto_debit_suggestion".localized),
                           in: view,
                           duration: ToastDuration.long)
        }
    }
    
    // MARK: - Actions
    @objc private func adjustBalanceTapped() {
        showAdjustBalanceSheet()
    }
    
    @objc private func refreshTapped() {
        viewModel.fetchData()
    }
    
    // MARK: - Configure
    private func configure() {
        nameLabel.text = viewModel.student.displayName
        balanceValueLabel.text = viewModel.balanceText
        let badge = viewModel.accountStatusStyle
        statusBadge.backgroundColor = badge.color
        statusLabel.attributedText = makeStatusAttributed(text: badge.text,
                                                          icon: badge.icon)
        let hasPending = viewModel.pendingPayment != nil
        confirmButton.isUserInteractionEnabled = hasPending
        confirmButton.alpha = hasPending ? 1.0 : 0.4
        dateLabel.text = viewModel.lastPaymentDateText
        lessonsValue.text = viewModel.lastPaymentLessonsText
        amountValue.text = viewModel.lastPaymentAmountText
        historyView.configure(
            totalText: viewModel.totalConfirmedText,
            rows: viewModel.historyPayments.map { makeHistoryRow(payment: $0) }
        )
    }
    
    // MARK: - Helper
    private func makeHistoryRow(payment: PaymentRequest) -> UIView {
        let container = UIView()
        let style = PaymentStatusMapper.style(for: payment.status)
        let dot = UIView()
        dot.backgroundColor = style.color
        dot.layer.cornerRadius = 4
        container.addSubview(dot)
        dot.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(8)
        }
        let dateLabel = UILabel()
        dateLabel.text = formatter.dateString(payment)
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .appTextSecondary
        container.addSubview(dateLabel)
        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.left.equalTo(dot.snp.right).offset(10)
        }
        let detailLabel = UILabel()
        detailLabel.text = formatter.detailText(payment)
        detailLabel.font = .systemFont(ofSize: 14, weight: .medium)
        detailLabel.textColor = .appText
        container.addSubview(detailLabel)
        detailLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(2)
            $0.left.equalTo(dot.snp.right).offset(10)
            $0.bottom.equalToSuperview().offset(-12)
        }
        let amountLabel = UILabel()
        amountLabel.text = formatter.amountString(payment)
        amountLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        amountLabel.textColor = style.color
        container.addSubview(amountLabel)
        amountLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().inset(16)
        }
        return container
    }
    
    private func makeStatusAttributed(text: String,
                                      icon: String) -> NSAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = UIImage(systemName: icon)?
            .withRenderingMode(.alwaysTemplate)
            .withTintColor(.white)
        attachment.bounds = CGRect(x: 0, y: -2, width: 11, height: 11)
        let result = NSMutableAttributedString(attachment: attachment)
        result.append(NSAttributedString(string: " \(text)"))
        return result
    }
}

// MARK: - Alerts
extension TeacherPaymentDetailViewController {
    private func showPaymentReview() {
        guard let payment = viewModel.pendingPayment else { return }
        router.showPaymentReview(
            payment: payment,
            settings: viewModel.settings,
            onConfirm: { [weak self] in
                self?.viewModel.confirmPayment()
            },
            onReject: { [weak self] in
                self?.viewModel.rejectPayment()
            },
            onEdit: { [weak self] newCount, review in
                guard let self,
                      var payment = viewModel.pendingPayment,
                      let price = viewModel.settings?.lessonPrice else {
                    return
                }
                payment.confirmedLessons = newCount
                payment.amount = Double(newCount) * price
                viewModel.updatePaymentLessons(payment)
                review.updatePayment(payment)
            }
        )
    }
    
    private func showAdjustBalanceSheet() {
        let current = viewModel.student.lessonsBalance ?? 0
        let alert = UIAlertController(
            title: "adjust_balance".localized,
            message: "adjust_balance_warning".localized,
            preferredStyle: .alert
        )
        alert.addTextField {
            $0.keyboardType = .numberPad
            $0.text = "\(current)"
        }
        alert.addAction(UIAlertAction(title: "cancel".localized,
                                      style: .cancel))
        alert.addAction(UIAlertAction(
            title: "adjust".localized,
            style: .destructive) { [weak self] _ in
                guard let text = alert.textFields?[0].text,
                      let newBalance = Int(text) else { return }
                self?.viewModel.adjustBalance(to: newBalance)
            }
        )
        present(alert, animated: true)
    }
    
    private func showClearHistoryAlert() {
        let alert = UIAlertController(
            title: "clear_history".localized,
            message: "clear_history_message".localized,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "cancel".localized,
                                      style: .cancel))
        alert.addAction(UIAlertAction(
            title: "clear".localized,
            style: .destructive) { [weak self] _ in
                self?.viewModel.clearHistory()
            }
        )
        present(alert, animated: true)
    }
}
