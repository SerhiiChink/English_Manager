//
//  TeacherPaymentsViewController.swift
//  English Manager
//
//  Created by Sergej Klepikov on 11.03.2026.
//

import UIKit
import SnapKit

final class TeacherPaymentsViewController: UIViewController {
    // MARK: - UI
    private let collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero,
                                  collectionViewLayout: .paymentLayout())
        cv.backgroundColor = .appBackground
        cv.register(PaymentCell.self,
                    forCellWithReuseIdentifier: PaymentCell.reuseId)
        return cv
    }()
    private let emptyStateView = EmptyStateView(
        icon: "person.2",
        title: "no_students_yet".localized,
        subtitle: "go_to_students_hint".localized
    )
        
    // MARK: - Properties
    private let router: TeacherRouterProtocol
    private let viewModel: TeacherPaymentsViewModelProtocol
    
    // MARK: - Init
    init(
        router: TeacherRouterProtocol,
        viewModel: TeacherPaymentsViewModelProtocol = TeacherPaymentsViewModel()
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
        setupNavіgationBar()
        bindViewModel()
        refreshController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchData()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .appBackground
        setupCollectionView()
        setupEmptyState()
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupEmptyState() {
        view.addSubview(emptyStateView)
        emptyStateView.isHidden = true
        emptyStateView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupNavіgationBar() {
        title = "payments".localized
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(settingTapped))
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            guard let self else { return }
            collectionView.endRefreshing()
            reloadData()
            showSettingsHintIfNeeded()
        }
        viewModel.onError = { [weak self] message in
            self?.collectionView.endRefreshing()
            self?.showAlert(title: "Error", message: message)
        }
    }
    
    // MARK: - Actions
    @objc private func settingTapped() {
        showSettingAlert()
    }
    
    @objc private func refreshTapped() {
        viewModel.fetchData()
    }
    
    // MARK: - Private
    private func reloadData() {
        let isEmpty = viewModel.students.isEmpty
        emptyStateView.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
        collectionView.reloadData()
    }
    
    private func refreshController() {
        collectionView.addRefreshControl(target: self,
                                         action: #selector(refreshTapped))
    }
    
    private func showSettingsHintIfNeeded() {
        guard viewModel.settings == nil else { return }
        guard !UserDefaults.standard.bool(
            forKey: UDKeys.paymentSettingsHint
        ) else { return }
        UserDefaults.standard.set(true,
                                  forKey: UDKeys.paymentSettingsHint)
        ToastView.show(.warning("setup_payment_settings".localized),
                       in: view,
                       duration: ToastDuration.long)
    }
}

// MARK: - UICollectionViewDataSource
extension TeacherPaymentsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        viewModel.students.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PaymentCell.reuseId, for: indexPath) as! PaymentCell
        let student = viewModel.students[indexPath.item]
        cell.configure(with: viewModel.cellMode(for: student))
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension TeacherPaymentsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let student = viewModel.students[indexPath.item]
        router.showTeacherPayment(student: student)
    }
}

// MARK: - Alerts
extension TeacherPaymentsViewController {
    private func showSettingAlert() {
        let current = viewModel .settings
        let alert = UIAlertController(title: "payment_settings".localized,
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addTextField() {
            $0.placeholder = "lesson_price_(UAH)".localized
            $0.keyboardType = .decimalPad
            $0.text = current.map { String($0.lessonPrice) }
        }
        alert.addTextField() {
            $0.placeholder = "min_lessons_to_pay".localized
            $0.keyboardType = .numberPad
            $0.text = current.map { String($0.minLessons) }
            
        }
        alert.addAction(UIAlertAction(title: "cancel".localized,
                                      style: .cancel))
        alert.addAction(UIAlertAction(
            title: "save".localized,
            style: .default) { [weak self] _ in
                guard let priceText = alert.textFields?[0].text,
                      let price = Double(priceText),
                      price > 0 else { return }
                let minLessons = Int(alert.textFields?[1].text ?? "") ?? 0
                self?.viewModel.saveSettings(price: price,
                                             minLessons: minLessons,
                                             currency: "UAH")
        })
        present(alert, animated: true)
    }
}
