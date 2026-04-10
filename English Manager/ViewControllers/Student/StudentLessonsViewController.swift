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
    private let collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero,
                                  collectionViewLayout: .lessonLayout())
        cv.backgroundColor = .appBackground
        cv.register(LessonCell.self,
                    forCellWithReuseIdentifier: LessonCell.reuseId)
        return cv
    }()
    private let emptyLabel = UILabel()
    
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
        setupCollectionView()
        setupEmptyLabel()
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
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
        navigationItem.title = "Lessons"
        navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            self?.collectionView.endRefreshing()
            self?.reloadData()
        }
        viewModel.onError = { [weak self] message in
            self?.collectionView.endRefreshing()
            self?.showAlert(title: "Error", message: message)
        }
    }
    
    // MARK: - Action
    @objc private func refreshTapped() {
        viewModel.fetchLessons()
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
        return cell
    }
}

    // MARK: - UICollectionViewDelegate
extension StudentLessonsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let lesson = viewModel.lessons[indexPath.item]
        router.showLessonDetail(lesson)
    }
}
