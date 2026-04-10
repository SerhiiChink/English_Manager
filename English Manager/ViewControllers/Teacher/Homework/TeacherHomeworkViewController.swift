//
//  TeacherHomeworkViewController.swift
//  English Manager
//
//  Created by Sergej Klepikov on 11.03.2026.
//

import UIKit

final class TeacherHomeworkViewController: UIViewController {
    // MARK: - UI
    private let contentView = HomeworkView()
    
    // MARK: - Properties
    private let router: TeacherRouterProtocol
    private var viewModel: TeacherHomeworkViewModelProtocol
    
    // MARK: - Init
    init(
        router: TeacherRouterProtocol,
        viewModel: TeacherHomeworkViewModelProtocol = TeacherHomeworkViewModel()
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
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContentView()
        setupNavigatorBar()
        bindViewModel()
        refreshContoller()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchHomework()
    }
    
    // MARK: - Setup
    private func setupContentView() {
        contentView.setDataSource(self)
        contentView.setDelegate(self)
    }
    
    private func setupNavigatorBar() {
        title = "Homework"
        navigationController?.isNavigationBarHidden = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease"),
            style: .plain,
            target: self,
            action: #selector(filterTapped)
        )
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            guard let self else { return }
            contentView.reloadData(isEmpty: viewModel.filteredHomeworks.isEmpty)
        }
        viewModel.onError = { [weak self] message in
            self?.contentView.endRefreshing()
            self?.showAlert(title: "Error", message: message)
        }
    }
    
    // MARK: - Actions
    @objc private func filterTapped() {
        showFilterAlert()
    }
    
    @objc private func refreshTapped() {
        viewModel.fetchHomework()
    }
    
    // MARK: - Private
    private func refreshContoller() {
        contentView.onRefresh = { [weak self] in
            self?.viewModel.fetchHomework()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension TeacherHomeworkViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        viewModel.filteredHomeworks.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HomeworkCell.reuseId,
            for: indexPath) as! HomeworkCell
        cell.configure(with: viewModel.filteredHomeworks[indexPath.item],
                       showStudent: true)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension TeacherHomeworkViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let homework = viewModel.filteredHomeworks[indexPath.item]
        router.showHomeworkDetail(homework) { [weak self] homework, grade, feedback in
            self?.viewModel.reviewHomework(homework,
                                           grade: grade,
                                           feedback: feedback)
        }
    }
}

// MARK: - Filter Alert
extension TeacherHomeworkViewController {
    private func showFilterAlert() {
        let alert = UIAlertController(title: "Filter",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(
            title: "All",
            style: .default) { [weak self] _ in
                self?.viewModel.filterByStudent(nil)
            }
        )
        viewModel.students.forEach { name in
            alert.addAction(UIAlertAction(
                title: name,
                style: .default) { [weak self] _ in
                    self?.viewModel.filterByStudent(name)
                }
            )
        }
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel))
        present(alert, animated: true)
    }
}
