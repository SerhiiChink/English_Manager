//
//  StudentHomeworkViewController.swift
//  English Manager
//
//  Created by Sergej Klepikov on 11.03.2026.
//

import UIKit

final class StudentHomeworkViewController: UIViewController {
    // MARK: - UI
    private let contentView = HomeworkView()
    
    // MARK: - Properties
    private let router: StudentRouterProtocol
    private var viewModel: StudentHomeworkViewModelProtocol
    
    // MARK: - Init
    init(
        router: StudentRouterProtocol,
        viewModel: StudentHomeworkViewModelProtocol = StudentHomeworkViewModel()
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
        setupNavigationBar()
        refreshContoller()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchHomeworks()
    }
    
    // MARK: - Setup
    private func setupContentView() {
        contentView.setDataSource(self)
        contentView.setDelegate(self)
    }
    
    private func setupNavigationBar() {
        title = "Homework"
        navigationController?.isNavigationBarHidden = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                            target: self,
                            action: #selector(addTapped))
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            guard let self else { return }
            contentView.reloadData(isEmpty: viewModel.homeworks.isEmpty)
        }
        viewModel.onError = { [weak self] message in
            self?.contentView.endRefreshing()
            self?.showAlert(title: "Error", message: message)
        }
    }
    
    // MARK: - Actions
    @objc private func addTapped() {
        showAddHomeworkAlert { [weak self] title, description, link in
            self?.viewModel.addHomework(title: title,
                                        description: description,
                                        link: link)
        }
    }
    
    // MARK: - Private
    private func refreshContoller() {
        contentView.onRefresh = { [weak self] in
            self?.viewModel.fetchHomeworks()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension StudentHomeworkViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        viewModel.homeworks.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HomeworkCell.reuseId,
            for: indexPath) as! HomeworkCell
        cell.configure(with: viewModel.homeworks[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension StudentHomeworkViewController: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView,
//                        didSelectItemAt indexPath: IndexPath) {
//        let homework = viewModel.homeworks[indexPath.item]
//        router.showHomeworkDetail(homework)
//    }
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        let homework = viewModel.homeworks[indexPath.item]
//        guard homework.status == .pending else { return nil }
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil) { _ in
                var actions: [UIMenuElement] = []
                if homework.status == .pending {
                    let edit = UIAction(
                        title: "Edit",
                        image: UIImage(systemName: "pencil")
                    ) { [weak self] _ in
                        self?.showEditHomeworkAlert(
                            homework: homework) { title, description, link in
                                self?.viewModel.updateHomework(
                                    homework,
                                    title: title,
                                    description: description,
                                    link: link
                                )
                            }
                    }
                    actions.append(edit)
                }
                let delete = UIAction(
                    title: "Delete",
                    image: UIImage(systemName: "trash"),
                    attributes: .destructive) { [weak self] _ in
                        self?.viewModel.deleteHomework(homework)
                    }
                actions.append(delete)
                return UIMenu(children: actions)
            }
    }
}

// MARK: - Add Homework Alerts
extension UIViewController {
    func showAddHomeworkAlert(
        onAdd: @escaping (String, String, String) -> Void
    ) {
        let alert = UIAlertController(title: "New Homework",
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Title" }
        alert.addTextField { $0.placeholder = "Description (optional)" }
        alert.addTextField {
            $0.placeholder = "Link (optional)"
            $0.keyboardType = .URL
            $0.autocapitalizationType = .none
        }
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel))
        alert.addAction(UIAlertAction(
            title: "Add",
            style: .default) { _ in
                guard let title = alert.textFields?[0].text,
                      !title.isEmpty else { return }
                let description = alert.textFields?[1].text ?? ""
                let link = alert.textFields?[2].text ?? ""
                onAdd(title, description, link)
            }
        )
        present(alert, animated: true)
    }
    
    func showEditHomeworkAlert(
        homework: Homework,
        onSave: @escaping (String, String, String) -> Void
    ) {
        let alert = UIAlertController(title: "Edit Homework",
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addTextField {
            $0.placeholder = "Title"
            $0.text = homework.title
        }
        alert.addTextField {
            $0.placeholder = "Description"
            $0.text = homework.description
        }
        alert.addTextField {
            $0.placeholder = "Link"
            $0.text = homework.sourceLink
            $0.keyboardType = .URL
            $0.autocapitalizationType = .none
        }
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel))
        alert.addAction(UIAlertAction(
            title: "Save",
            style: .default) { _ in
                guard let title = alert.textFields?[0].text,
                      !title.isEmpty else { return }
                let description = alert.textFields?[1].text ?? ""
                let link = alert.textFields?[2].text ?? ""
                onSave(title, description, link)
            }
        )
        present(alert, animated: true)
    }
}

