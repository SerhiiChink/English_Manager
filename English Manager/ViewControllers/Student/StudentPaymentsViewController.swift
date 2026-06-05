//
//  StudentPaymentsViewController.swift
//  English Manager
//
//  Created by Sergej Klepikov on 11.03.2026.
//

import UIKit
import SnapKit

final class StudentPaymentsViewController: UIViewController {
    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let balanceCard = UIView()
    private let balanceLabel = UILabel()
    private let priceTitleLabel = UILabel()
    private let priceLabel = UILabel()
    private let minTitleLabel = UILabel()
    private let minLabel = UILabel()
    private let statusBadge = UIView()
    private let statusLabel = UILabel()
    private let historyView = PaymentHistoryView()
    private let payButton = UIButton(type: .custom)
    private let infoButton = UIBarButtonItem()
    
    // MARK: - Properties
    private let router: StudentRouterProtocol
    private var viewModel: StudentPaymentsViewModelProtocol
    private let formatter: PaymentFormatterProtocol = PaymentFormatter()
    
    // MARK: - Init
    init(
        router: StudentRouterProtocol,
        viewModel: StudentPaymentsViewModelProtocol = StudentPaymentsViewModel()
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refresh()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .appBackground
        setupScrollView()
        setupBalanceCard()
        setupHistoryCard()
        setupPayButton()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.addRefreshControl(target: self,
                                     action: #selector(refreshTapped))
        scrollView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(Layout.buttonHeight + 16)
        }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
    }
    
    private func setupBalanceCard() {
        balanceCard.styleAsCard()
        contentView.addSubview(balanceCard)
        balanceCard.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.left.right.equalToSuperview().inset(Layout.padding)
        }
        setupStatusBadge()
        setupBalanceLabel()
        setupPriceLabel()
        setupMinimumLessonsLabel()
    }
    
    private func setupStatusBadge() {
        statusBadge.layer.cornerRadius = 8
        balanceCard.addSubview(statusBadge)
        statusBadge.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.right.equalToSuperview().inset(16)
            $0.height.equalTo(20)
        }
        statusLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        statusLabel.textColor = .white
        statusBadge.addSubview(statusLabel)
        statusLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.right.equalToSuperview().inset(8)
        }
    }
    
    private func setupBalanceLabel() {
        let balanceTitleLabel = UILabel()
        balanceTitleLabel.text = "balance".localized
        balanceTitleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        balanceTitleLabel.textColor = .appTextSecondary
        balanceCard.addSubview(balanceTitleLabel)
        balanceTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.left.equalToSuperview().offset(16)
        }
        balanceLabel.font = .systemFont(ofSize: 36, weight: .bold)
        balanceLabel.textColor = .appAccent
        balanceCard.addSubview(balanceLabel)
        balanceLabel.snp.makeConstraints {
            $0.top.equalTo(balanceTitleLabel.snp.bottom).offset(4)
            $0.left.equalToSuperview().offset(16)
        }
    }
    
    private func setupPriceLabel() {
        priceTitleLabel.text = "lesson_price".localized
        priceTitleLabel.font = .systemFont(ofSize: 13)
        priceTitleLabel.textColor = .appTextSecondary
        balanceCard.addSubview(priceTitleLabel)
        priceTitleLabel.snp.makeConstraints {
            $0.top.equalTo(balanceLabel.snp.bottom).offset(16)
            $0.left.equalToSuperview().offset(16)
        }
        priceLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        priceLabel.textColor = .appText
        balanceCard.addSubview(priceLabel)
        priceLabel.snp.makeConstraints {
            $0.centerY.equalTo(priceTitleLabel)
            $0.right.equalToSuperview().inset(16)
        }
    }
    
    private func setupMinimumLessonsLabel() {
        minTitleLabel.text = "minimum_lessons".localized
        minTitleLabel.font = .systemFont(ofSize: 13)
        minTitleLabel.textColor = .appTextSecondary
        balanceCard.addSubview(minTitleLabel)
        minTitleLabel.snp.makeConstraints {
            $0.top.equalTo(priceTitleLabel.snp.bottom).offset(12)
            $0.left.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-16)
        }
        minLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        minLabel.textColor = .appText
        balanceCard.addSubview(minLabel)
        minLabel.snp.makeConstraints {
            $0.centerY.equalTo(minTitleLabel)
            $0.right.equalToSuperview().inset(16)
        }
    }
    
    private func setupHistoryCard() {
        contentView.addSubview(historyView)
        historyView.onClear = { [weak self] in
            self?.showClearHistoryAlert()
        }
        historyView.snp.makeConstraints {
            $0.top.equalTo(balanceCard.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }

    private func setupPayButton() {
        var config = UIButton.Configuration.filled()
        var attr = AttributeContainer()
        attr.font = .systemFont(ofSize: 16, weight: .semibold)
        config.attributedTitle = AttributedString("pay_for_lessons".localized,
                                                  attributes: attr)
        config.baseBackgroundColor = .appAccent
        config.background.cornerRadius = Layout.cornerRadius
        config.cornerStyle = .fixed
        payButton.configuration = config
        payButton.layer.cornerRadius = Layout.cornerRadius
        payButton.addAction(UIAction { [weak self] _ in
            self?.showPaymentAlert()
        }, for: .touchUpInside)
        view.addSubview(payButton)
        payButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.height.equalTo(Layout.buttonHeight)
        }
    }
    
    private func setupNavigationBar() {
        title = "payments".localized
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        infoButton.image = UIImage(systemName: "questionmark.circle")
        infoButton.style = .plain
        infoButton.target = self
        infoButton.action = #selector(infoTapped)
        navigationItem.rightBarButtonItem = infoButton
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
    }
    
    // MARK: - Actions
    @objc private func refreshTapped() {
        viewModel.refresh()
    }
    
    @objc private func infoTapped() {
        showAlert(title: "how_to_pay".localized,
                  message: "payment_instruction".localized)
    }
    
    // MARK: - Configure
    private func configure() {
        balanceLabel.text = viewModel.balanceText
        let badge = viewModel.accountStatusStyle
        statusBadge.backgroundColor = badge.color
        statusLabel.text = badge.text
        priceLabel.text = viewModel.priceText
        minLabel.text = viewModel.minLessonsText
        historyView.configure(
            totalText: viewModel.totalPaidText,
            payments: viewModel.payments
        )
        payButton.isUserInteractionEnabled = !viewModel.hasPendingPayment
        payButton.alpha = viewModel.hasPendingPayment ? 0.4 : 1.0
    }
}

// MARK: - Alert
extension StudentPaymentsViewController {
    private func showPaymentAlert() {
        switch viewModel.paymentAvailability {
        case .unavailable:
            showAlert(title: "error".localized,
                      message: "payment_not_configured_error".localized)
        case .priceOnly(let price):
            confirmSingleLesson(price: price)
        case .full(let price, let minLessons):
            showFullPaymentAlert(price: price, minLessons: minLessons)
        }
    }
    
    private func confirmSingleLesson(price: Double) {
        let alert = UIAlertController(
            title: "pay for lessons".localized,
            message: "1 lesson · \(Int(price)) UAH",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "cancel".localized,
                                      style: .cancel))
        alert.addAction(UIAlertAction(
            title: "send".localized,
            style: .default) { [weak self] _ in
                self?.viewModel.createPayment(lessonsCount: 1)
            }
        )
        present(alert, animated: true)
    }
    
    private func showFullPaymentAlert(price: Double, minLessons: Int) {
        let settings = TeacherSettings(
            teacherId: "",
            lessonPrice: price,
            minLessons: minLessons,
            currency: viewModel.settings?.currency ?? "UAH"
        )
        let alert = UIAlertController(
            title: "pay for lessons".localized,
            message: formatter.paymentAlertMessage(settings: settings),
            preferredStyle: .alert
        )
        alert.addTextField {
            $0.placeholder = "Number of lessons (min \(minLessons)"
            $0.keyboardType = .numberPad
            $0.text = String(minLessons)
        }
        alert.addAction(UIAlertAction(title: "cancel".localized,
                                      style: .cancel))
        alert.addAction(UIAlertAction(
            title: "send".localized,
            style: .default) { [weak self] _ in
                guard let text = alert.textFields?[0].text,
                      let count = Int(text),
                      count >= minLessons else {
                    self?.showAlert(
                        title: "invalid_amount".localized,
                        message: self?.formatter.invalidAmountMessage(settings: settings) ?? ""
                    )
                    return
                }
                self?.viewModel.createPayment(lessonsCount: count)
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
