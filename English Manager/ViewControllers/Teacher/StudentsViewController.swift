//
//  StudentsViewController.swift
//  English Manager
//
//  Created by Sergej Klepikov on 11.03.2026.
//

import UIKit
import SnapKit

final class StudentsViewController: UIViewController {
    // MARK: - UI
    private let collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero,
                                  collectionViewLayout: .studentLayout())
        cv.backgroundColor = .appBackground
        cv.register(StudentCell.self,
                    forCellWithReuseIdentifier: StudentCell.reuseId)
        return cv
    }()
    private let emptyStateView = EmptyStateView(
        icon: "person.badge.plus",
        title: "no_students_yet".localized,
        subtitle: "add_first_student_hint".localized,
        action: "add_student".localized,
        onAction: nil)
    
    // MARK: - Properties
    private let router: TeacherRouterProtocol
    private var viewModel: StudentsViewModelProtocol
    
    // MARK: - Init
    init(
        router: TeacherRouterProtocol,
        viewModel: StudentsViewModelProtocol = StudentsViewModel()
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
        viewModel.fetchStudents()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .appBackground
        setupCollectionView()
        setupEmptyState()
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
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
        emptyStateView.onAction = { [weak self] in
            self?.showAddStudentAlert()
        }
    }
    
    private func setupNavigationBar() {
        title = "students".localized
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addStudentTapped))
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
    
    // MARK: - Actions
    @objc private func addStudentTapped() {
        showAddStudentAlert()
    }
    
    @objc private func refreshTapped() {
        viewModel.fetchStudents()
    }
    
    // MARK: - Private
    private func reloadData() {
        let isEmpty = viewModel.students.isEmpty
        collectionView.isHidden = isEmpty
        emptyStateView.isHidden = !isEmpty
        collectionView.reloadData()
    }
    
    private func refreshContoller() {
        collectionView.addRefreshControl(target: self, action: #selector(refreshTapped))
    }
}

    // MARK: - UICollectionViewDataSource
extension StudentsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        viewModel.students.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: StudentCell.reuseId,
            for: indexPath) as! StudentCell
        let student = viewModel.students[indexPath.item]
        cell.configure(with: student)
        cell.setMenuActions([
            .remove { [weak self] in
                self?.viewModel.removeStudent(student)
            }
        ])
        return cell
    }
}

    // MARK: - UICollectionViewDelegate
extension StudentsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
    }
}

    // MARK: - Alerts
extension StudentsViewController {
    private func showAddStudentAlert() {
        let alert = UIAlertController(
            title: "add_student".localized,
            message: nil,
            preferredStyle: .alert
        )
        alert.addTextField {
            $0.placeholder = "email".localized
            $0.keyboardType = .emailAddress
            $0.autocapitalizationType = .none
        }
        alert.addAction(UIAlertAction(title: "cancel".localized,
                                      style: .cancel)
        )
        alert.addAction(UIAlertAction(
            title: "add".localized,
            style: .default) { [weak self] _ in
                guard let email = alert.textFields?[0].text,
                      !email.isEmpty else { return }
                self?.viewModel.addStudent(email: email)
            })
        present(alert, animated: true)
    }
}
