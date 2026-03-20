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
//    private let activityIndicator =  UIActivityIndicatorView(style: .medium)
    private let emptyLabel = UILabel()
    
    // MARK: - Properties
    private weak var router: AuthRouterProtocol?
    private var viewModel: StudentsViewModelProtocol
    
    // MARK: - Init
    init(
        router: AuthRouterProtocol?,
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
//        setupActivityIndicator()
        setupEmptyLabel()
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
//    private func setupActivityIndicator() {
//        activityIndicator.hidesWhenStopped = true
//        view.addSubview(activityIndicator)
//        activityIndicator.snp.makeConstraints {
//            $0.center.equalToSuperview()
//        }
//    }
    
    private func setupEmptyLabel() {
        emptyLabel.text = "No students yet"
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
        title = "Students"
        navigationController?.isNavigationBarHidden = false
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
//        viewModel.onLoading = { [weak self] isLoading in
//            isLoading
//            ? self?.activityIndicator.startAnimating()
//            : self?.activityIndicator.stopAnimating()
//        }
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
//        activityIndicator.stopAnimating()
        let isEmpty = viewModel.students.isEmpty
        emptyLabel.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
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
        cell.configure(with: viewModel.students[indexPath.item])
        return cell
    }
}

    // MARK: - UICollectionViewDelegate
extension StudentsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        let student = viewModel.students[indexPath.item]
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil) { _ in
                let delete = UIAction(
                    title: "Delete",
                    image: UIImage(systemName: "trash"),
                    attributes: .destructive) { [weak self] _ in
                        self?.viewModel.removeStudent(student)
                }
                return UIMenu(children: [delete])
        }
    }
}

    // MARK: - Alerts
extension StudentsViewController {
    private func showAddStudentAlert() {
        let alert = UIAlertController(
            title: "Add Student",
            message: nil,
            preferredStyle: .alert
        )
        alert.addTextField {
            $0.placeholder = "Email"
            $0.keyboardType = .emailAddress
            $0.autocapitalizationType = .none
        }
        alert .addTextField {
            $0.placeholder = "Name(optional)"
        }
        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel)
        )
        alert.addAction(UIAlertAction(
            title: "Add",
            style: .default) { [weak self] _ in
                guard let email = alert.textFields?[0].text,
                      !email.isEmpty else { return }
                let name = alert.textFields?[1].text ?? ""
                self?.viewModel.addStudent(email: email, name: name)
            })
        present(alert, animated: true)
    }
}
