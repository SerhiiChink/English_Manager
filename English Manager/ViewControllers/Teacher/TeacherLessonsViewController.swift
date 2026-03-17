//
//  TeacherLessonsViewController.swift
//  English Manager
//
//  Created by Sergej Klepikov on 11.03.2026.
//

import UIKit
import SnapKit

final class TeacherLessonsViewController: UIViewController {
    // MARK: - UI
    private let collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero,
                                  collectionViewLayout: .lessonLayout())
        cv.backgroundColor = .appBackground
        cv.register(LessonCell.self,
                    forCellWithReuseIdentifier: LessonCell.reuseId)
        return cv
    }()
    private let activityIndicator =  UIActivityIndicatorView(style: .medium)
    private let emptyLabel = UILabel()
    
    // MARK: - Properties
    private weak var router: AuthRouterProtocol?
    private var viewModel: TeacherLessonsViewModelProtocol
    private let formatter: LessonFormatterProtocol = LessonFormatter()
    
    // MARK: - Init
    init(
        router: AuthRouterProtocol?,
        viewModel: TeacherLessonsViewModelProtocol = TeacherLessonsViewModel()
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
        viewModel.fetchLessons()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .appBackground
        setupCollectionView()
        setupActivityIndicator()
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
    
    private func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    private func setupEmptyLabel() {
        emptyLabel.text = "No lessons yet"// localiz
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
        title = "Lessons"
        navigationController?.isNavigationBarHidden = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addLessonTapped)
        )
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
            self?.reloadData()
        }
        viewModel.onError = { [weak self] message in
            self?.showAlert(title: "Error", message: message)
        }
        viewModel.onLoading = { [weak self] isLoading in
            isLoading
            ? self?.activityIndicator.startAnimating()
            : self?.activityIndicator.stopAnimating()
        }
    }
    
    // MARK: - Actions
    @objc private func addLessonTapped() {
        showAddLessonAlert()
    }
    
    @objc private func filterTapped() {
        showFilterAlert()
    }
    
    // MARK: - Private
    private func createLesson(
        student: User,
        topic: String,
        bookTitle: String,
        pages: String,
        urlText: String
    ) {
        guard let teacherId = viewModel.currentTeacherId else { return }
        let sourceLinks: [SourceLink] = urlText.isEmpty ? [] : [
            SourceLink(url: urlText, title: urlText),
        ]
        let lesson = Lesson(
            studentId: student.id,
            teacherId: teacherId,
            studentName: student.name.isEmpty
                ? student.email
                : student.name,
            date: Date(),
            topic: topic,
            bookTitle: bookTitle,
            pages: pages,
            attended: true,
            vocabulary: [],
            sourceLinks: sourceLinks
        )
        viewModel.addLesson(lesson)
    }
    
    private func reloadData() {
        let isEmpty = viewModel.filteredLessons.isEmpty
        emptyLabel.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
        collectionView.reloadData()
    }
}

    // MARK: - UICollectionViewDataSource
extension TeacherLessonsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        viewModel.filteredLessons.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: LessonCell.reuseId,
            for: indexPath) as! LessonCell
        cell.configure(with: viewModel.filteredLessons[indexPath.item])
        return cell
    }
}

    // MARK: - UICollectionViewDelegateFlowLayout
extension TeacherLessonsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        let lesson = viewModel.filteredLessons[indexPath.item]
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil) { _ in
                let edit = UIAction(
                    title: "Edit",
                    image: UIImage(systemName: "pencil")) { [weak self] _ in
                        self?.showEditLesson(lesson: lesson)
                    }
                let delete = UIAction(
                    title: "Delete",
                    image: UIImage(systemName: "trash"),
                    attributes: .destructive
                ) { [weak self] _ in
                    self?.viewModel.deleteLesson(lesson: lesson)
                }
                return UIMenu(children: [edit, delete])
            }
    }
}

    // MARK: - TeacherLessonsViewController+Alerts
extension TeacherLessonsViewController {
    func showAddLessonAlert() {
        showStudentPickerAlert { [weak self] student in
            self?.showLessonFormAlert(student: student)
        }
    }
    
    private func showStudentPickerAlert(onSelect: @escaping (User) -> Void) {
        let students = viewModel.students
        guard !students.isEmpty else {
            showAlert(title: "NoStudents",
                      message: "Add students first in Students tab")
            return
        }
        let alert = UIAlertController(title: "Select student",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        students.forEach { student in
            let name = student.name.isEmpty
            ? student.email
            : student.name
            alert.addAction(UIAlertAction(title: name,
                                          style: .default) { _ in
                onSelect(student)
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel))
        present(alert, animated: true)
    }
    
    func showLessonFormAlert(student: User) {
        let alert = UIAlertController(
            title: "New Lesson",
            message: student.name.isEmpty ? student.email : student.name,
            preferredStyle: .alert
        )
        alert.addTextField { $0.placeholder = "Topic" }
        alert.addTextField { $0.placeholder = "Book title" }
        alert.addTextField { $0.placeholder = "Pages" }
        alert.addTextField { $0.placeholder = "Source URl (optional)" }
        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel
        ))
        alert.addAction(UIAlertAction(
            title: "Add",
            style: .default) { [weak self] _ in
                guard let self,
                      let topic = alert.textFields?[0].text,
                      let bookTitle = alert.textFields?[1].text,
                      let pages = alert.textFields?[2].text,
                      let urlText = alert.textFields?[3].text,
                      !topic.isEmpty else { return }
                if !urlText.isEmpty,
                   let duplicate = self.viewModel.checkDuplicateLink(urlText) {
                    self.showDuplicateLinkAlert(
                        url: urlText,
                        duplicate: duplicate,
                        student: student,
                        topic: topic,
                        bookTitle: bookTitle,
                        pages: pages
                    )
                    return
                }
                self.createLesson(student: student,
                                  topic: topic,
                                  bookTitle: bookTitle,
                                  pages: pages,
                                  urlText: urlText)
            }
        )
        present(alert, animated: true)
    }
    
    private func showDuplicateLinkAlert(
        url: String,
        duplicate: Lesson,
        student: User,
        topic: String,
        bookTitle: String,
        pages: String
    ) {
        let dateString = formatter.lessonDateString(for: duplicate)
        let alert = UIAlertController(
            title: "Link already used",
            message: "This source was used in lesson with \(duplicate.studentName) on \(dateString). Add anyway?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel))
        alert.addAction(UIAlertAction(title: "Add anyway",
                                      style: .default) { [weak self] _ in
            self?.createLesson(
                student: student,
                topic: topic,
                bookTitle: bookTitle,
                pages: pages,
                urlText: url
            )
        })
        present(alert, animated: true)
    }
    
    private func showFilterAlert() {
        let alert = UIAlertController(
            title: "Filter",
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "All lessons",
                                      style: .default) { [weak self] _ in
            self?.viewModel.filterByStudent(nil)
        })
        viewModel.students.forEach { student in
            let name = student.name.isEmpty
            ? student.email
            : student.name
            alert.addAction(UIAlertAction(
                title: name,
                style: .default) { [weak self] _ in
                    self?.viewModel.filterByStudent(student.id)
                })
        }
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel))
        present(alert, animated: true)
    }
    
    func showEditLesson(lesson: Lesson) {
        let alert = UIAlertController(
            title: "Edit lesson",
            message: lesson.studentName,
            preferredStyle: .alert
        )
        alert.addTextField {
            $0.placeholder = "Topic"
            $0.text = lesson.topic
        }
        alert.addTextField {
            $0.placeholder = "Book title"
            $0.text = lesson.bookTitle
        }
        alert.addTextField {
            $0.placeholder = "Pages"
            $0.text = lesson.pages
        }
        alert.addTextField {
            $0.placeholder = "Source URL"
            $0.text = lesson.sourceLinks.first?.url ?? ""
        }
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel))
        alert.addAction(UIAlertAction(title: "Save",
                                      style: .default) { [weak self] _ in
            guard let topic = alert.textFields?[0].text,
                  let bookTitle = alert.textFields?[1].text,
                  let pages = alert.textFields?[2].text,
                  let urlText = alert.textFields?[3].text,
            !topic.isEmpty else { return }
            let sourceLink: [SourceLink] = urlText.isEmpty ? [] : [
                SourceLink(url: urlText, title: urlText)
            ]
            var updatedLesson = lesson
            updatedLesson.topic = topic
            updatedLesson.bookTitle = bookTitle
            updatedLesson.pages = pages
            updatedLesson.sourceLinks = sourceLink
            self?.viewModel.updateLesson(updatedLesson)
        })
        present(alert, animated: true)
    }
}
