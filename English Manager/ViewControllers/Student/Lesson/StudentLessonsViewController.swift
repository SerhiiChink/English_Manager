//
//  StudentLessonsViewController.swift
//  English Manager
//
//  Created by Sergej Klepikov on 11.03.2026.
//

import UIKit
import SnapKit

final class StudentLessonsViewController: UIViewController {
    // MARK: - UI
    private let scheduleBanner: StudentScheduleBannerView = {
        let view = StudentScheduleBannerView()
        view.isHidden = true
        return view
        
    }()
    private let collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero,
                                  collectionViewLayout: .lessonLayout())
        cv.backgroundColor = .appBackground
        cv.register(LessonCell.self,
                    forCellWithReuseIdentifier: LessonCell.reuseId)
        return cv
    }()
    private let emptyLabel = UILabel()
    private var autoDebitButton: UIBarButtonItem?
    
    // MARK: - Properties
    private let router: StudentRouterProtocol
    private var viewModel: StudentLessonsViewModelProtocol
    
    // MARK: - Init
    init(
        router: StudentRouterProtocol,
        viewModel: StudentLessonsViewModelProtocol = StudentLessonsViewModel()
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
        refreshContoller()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchLessons()
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .appBackground
        setupScheduleBanner()
        setupCollectionView()
        setupEmptyLabel()
    }
    
    private func setupScheduleBanner() {
        view.addSubview(scheduleBanner)
        scheduleBanner.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            $0.left.right.equalToSuperview().inset(Layout.padding)
        }
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.snp.makeConstraints {
            $0.top.equalTo(scheduleBanner.snp.bottom).offset(8)
            $0.left.right.bottom.equalToSuperview()
        }
    }
    
    private func setupEmptyLabel() {
        emptyLabel.text = "No lessons yet"
        emptyLabel.textColor = .appTextSecondary
        emptyLabel.font = .systemFont(ofSize: 16)
        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true
        view.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "lessons_capitalized".localized
        navigationController?.isNavigationBarHidden = false
        autoDebitButton = UIBarButtonItem(
            image: UIImage(systemName: "bolt.circle"),
            style: .plain,
            target: self,
            action: #selector(autoDebitTapped))
        navigationItem.rightBarButtonItem = autoDebitButton
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            guard let self else { return }
            collectionView.endRefreshing()
            scheduleBanner.configure(schedules: viewModel.schedules)
            updateAutoDebitButton()
            reloadData()
        }
        viewModel.onError = { [weak self] message in
            self?.collectionView.endRefreshing()
            self?.showAlert(title: "Error", message: message)
        }
        viewModel.onTeacherAssigned = { [weak self] in
            guard let self else { return }
            ToastView.show(.success("you_added_to_lessons".localized),
                           in: view,
                           duration: ToastDuration.long)
        }
    }
    
    // MARK: - Action
    @objc private func refreshTapped() {
        viewModel.refresh()
    }
    
    @objc private func autoDebitTapped() {
        let hasSchedule = !viewModel.schedules.isEmpty
        hasSchedule ? showAutoPayStatusAlert() : showAutoPayInfoAlert()
    }
    
    // MARK: - Private
    private func reloadData() {
        let isEmpty = viewModel.lessons.isEmpty
        emptyLabel.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
        collectionView.reloadData()
    }
    
    private func refreshContoller() {
        collectionView.addRefreshControl(target: self, action: #selector(refreshTapped))
    }
    
    private func updateAutoDebitButton() {
        let hasSchedule = !viewModel.schedules.isEmpty
        let isEnabled = viewModel.isAutoDebitEnabled
        let iconName = (hasSchedule && isEnabled)
            ? "bolt.circle.fill"
            : "bolt.circle"
        let color: UIColor
        if !hasSchedule {
            color = .appTextSecondary
        } else {
            color = isEnabled ? .appGreen : .appRed
        }
        autoDebitButton?.image = UIImage(systemName: iconName)
        autoDebitButton?.tintColor = color
    }
    
    // MARK: - Helper
    private func showAutoPayInfoAlert() {
        showAlert(title: "auto_debit".localized,
                  message: "auto_debit_description".localized)
    }
    
    private func showAutoPayStatusAlert() {
        showAlert(title: viewModel.isAutoDebitEnabled
                    ? "auto_pay_on".localized
                    : "auto_pay_off".localized,
                  message: nil)
    }
}

    // MARK: - UICollectionViewDataSource
extension StudentLessonsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        viewModel.lessons.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: LessonCell.reuseId,
            for: indexPath) as! LessonCell
        cell.configure(with: viewModel.lessons[indexPath.item])
        cell.hideMenu()
        return cell
    }
}

    // MARK: - UICollectionViewDelegate
extension StudentLessonsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let lesson = viewModel.lessons[indexPath.item]
        router.showLessonDetail(lesson,
                                teacherName: viewModel.teacherName)
    }
}
