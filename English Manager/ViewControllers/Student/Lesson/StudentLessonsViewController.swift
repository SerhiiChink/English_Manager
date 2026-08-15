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
    private let emptyStateView = EmptyStateView(
        icon: "calendar.badge.clock",
        title: "no_lessons_yet".localized,
        subtitle: "student_lessons_hint".localized
    )
    
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
        UNUserNotificationCenter.current().setBadgeCount(
            0,
            withCompletionHandler: nil
        )
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .appBackground
        setupScheduleBanner()
        setupCollectionView()
        setupEmptyState()
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
    
    private func setupEmptyState() {
        view.addSubview(emptyStateView)
        emptyStateView.isHidden = true
        emptyStateView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "lessons_capitalized".localized
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            guard let self else { return }
            collectionView.endRefreshing()
            scheduleBanner.configure(
                schedules: viewModel.schedules,
                rescheduledLessons: viewModel.rescheduledLessons,
                timezone: viewModel.teacherTimezone
            )
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
    
    // MARK: - Private
    private func reloadData() {
        let isEmpty = viewModel.lessons.isEmpty
        emptyStateView.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
        collectionView.reloadData()
    }
    
    private func refreshContoller() {
        collectionView.addRefreshControl(target: self, action: #selector(refreshTapped))
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
