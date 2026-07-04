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
    private let scheduleView = StudentScheduleView()
    private let collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero,
                                  collectionViewLayout: .lessonLayout())
        cv.backgroundColor = .appBackground
        cv.register(LessonCell.self,
                    forCellWithReuseIdentifier: LessonCell.reuseId)
        return cv
    }()
    private let noStudentsState = EmptyStateView(
        icon: "person.2",
        title: "no_students_yet".localized,
        subtitle: "go_to_students_hint".localized
    )
    private let noLessonsState = EmptyStateView(
        icon: "calendar.badge.clock",
        title: "no_lessons_yet".localized,
        subtitle: "tap_student_to_add_schedule".localized
    )
    
    // MARK: - Properties
    private let router: TeacherRouterProtocol
    private var viewModel: TeacherLessonsViewModelProtocol
    private let formatter: LessonFormatterProtocol = LessonFormatter()
    private let scheduleFormatter: ScheduleFormatterProtocol = ScheduleFormatter()
    
    // MARK: - Init
    init(
        router: TeacherRouterProtocol,
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
        refreshContoller()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchLessons()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .appBackground
        setupScheduleView()
        setupCollectionView()
        setupEmptyState()
    }
    
    private func setupScheduleView() {
        view.addSubview(scheduleView)
        scheduleView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.right.equalToSuperview()
        }
        scheduleView.onStudentTapped = { [weak self] student in
            self?.showScheduleOptions(for: student)
        }
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.snp.makeConstraints {
            $0.top.equalTo(scheduleView.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
    }
    
    private func setupEmptyState() {
        [noStudentsState, noLessonsState].forEach {
            view.addSubview($0)
            $0.isHidden = true
            $0.snp.makeConstraints {
                $0.center.equalToSuperview()
                $0.left.right.equalToSuperview().inset(32)
            }
        }
    }
    
    private func setupNavigationBar() {
        title = "lessons_capitalized".localized
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
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
            guard let self else { return }
            self.collectionView.endRefreshing()
            self.reloadData()
            self.scheduleView.configure(student: self.viewModel.students,
                                        schedule: self.viewModel.schedules)
        }
        viewModel.onError = { [weak self] message in
            self?.collectionView.endRefreshing()
            self?.showAlert(title: "Error", message: message)
        }
    }
    
    // MARK: - Actions
    @objc private func addLessonTapped() {
        showAddLessonAlert()
    }
    
    @objc private func filterTapped() {
        showFilterAlert()
    }
    
    @objc private func refreshTapped() {
        viewModel.fetchLessons()
    }
    
    // MARK: - Private
    private func createLesson(
        student: User,
        topic: String,
        description: String,
        pages: String,
        urlText: String,
        occurrence: LessonOccurrence?
    ) {
        guard let teacherId = viewModel.currentTeacherId else { return }
        let sourceLinks: [SourceLink] = urlText.isEmpty ? [] : [
            SourceLink(url: urlText, title: urlText),
        ]
        let lesson = Lesson(
            studentId: student.id,
            teacherId: teacherId,
            occurrenceId: occurrence?.id,
            studentName: student.displayName,
            date: occurrence?.scheduledAt ?? Date(),
            topic: topic,
            bookTitle: description,
            pages: pages,
            attended: true,
            vocabulary: [],
            sourceLinks: sourceLinks
        )
        viewModel.addLesson(lesson, occurrence: occurrence)
    }
    
    private func reloadData() {
        let hasStudents = !viewModel.students.isEmpty
        let hasLessons = !viewModel.filteredLessons.isEmpty
        noStudentsState.isHidden = hasStudents
        noLessonsState.isHidden = !hasStudents || hasLessons
        collectionView.isHidden = !hasLessons
        collectionView.reloadData()
    }
    
    private func refreshContoller() {
        collectionView.addRefreshControl(target: self, action: #selector(refreshTapped))
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
        let lesson = viewModel.filteredLessons[indexPath.item]
        cell.configure(with: lesson)
        cell.setMenuActions([
            .edit { [weak self] in
                self?.showEditLesson(lesson: lesson)
            },
            .delete { [weak self] in
                self?.viewModel.deleteLesson(lesson: lesson) { index in
                    guard let index else { return }
                    self?.collectionView.performBatchUpdates {
                        self?.collectionView.deleteItems(
                            at: [IndexPath(item: index, section: 0)]
                        )
                    }
                }
            }
        ])
        return cell
    }
}

    // MARK: - UICollectionViewDelegate
extension TeacherLessonsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
    }
}

    // MARK: - TeacherLessonsViewController+Alerts
extension TeacherLessonsViewController {
    func showAddLessonAlert() {
        showStudentPickerAlert { [weak self] student in
            guard let self else { return }
            let schedules = viewModel.schedules(for: student.id)
            if schedules.isEmpty {
                showLessonFormAlert(student: student, occurrence: nil)
            } else {
                showOccurrencePickerAlert(student: student,
                                          schedule: schedules)
            }
        }
    }
    
    private func showOccurrencePickerAlert(student: User,
                                           schedule: [Schedule]) {
        let alert = UIAlertController(title: student.displayName,
                                      message: "select_schedule".localized,
                                      preferredStyle: .actionSheet)
        schedule.forEach { schedule in
            let title = scheduleFormatter.formatted(schedule,
                                                    timezone: nil)
            let occurrence = viewModel.nextOccurrence(for: schedule)
            alert.addAction(UIAlertAction(
                title: title,
                style: .default
            ) { [weak self] _ in
                guard let self else { return }
                self.showLessonFormAlert(student: student,
                                          occurrence: occurrence)
            })
        }
        alert.addAction(UIAlertAction(title: "skip".localized,
                                      style: .cancel) { [weak self] _ in
            self?.showLessonFormAlert(student: student, occurrence: nil)
        })
        present(alert, animated: true)
    }
    
    private func showStudentPickerAlert(onSelect: @escaping (User) -> Void) {
        let students = viewModel.students
        guard !students.isEmpty else {
            showAlert(title: "no_students".localized,
                      message: "add_students_first".localized)
            return
        }
        let alert = UIAlertController(title: "select_student".localized,
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
        alert.addAction(UIAlertAction(title: "cancel".localized,
                                      style: .cancel))
        present(alert, animated: true)
    }
    
    func showLessonFormAlert(student: User, occurrence: LessonOccurrence?) {
        let alert = UIAlertController(
            title: "new_lesson".localized,
            message: student.displayName,
            preferredStyle: .alert
        )
        alert.addTextField { $0.placeholder = "topic".localized }
        alert.addTextField { $0.placeholder = "description".localized }
        alert.addTextField { $0.placeholder = "pages".localized }
        alert.addTextField { $0.placeholder = "source_url_optional".localized }
        alert.addAction(UIAlertAction(title: "cancel".localized,
                                      style: .cancel))
        alert.addAction(UIAlertAction(
            title: "add".localized,
            style: .default) { [weak self] _ in
                guard let self,
                      let topic = alert.textFields?[0].text,
                      let description = alert.textFields?[1].text,
                      let pages = alert.textFields?[2].text,
                      let urlText = alert.textFields?[3].text else { return }
                if !urlText.isEmpty,
                   let duplicate = self.viewModel.checkDuplicateLink(urlText) {
                    showDuplicateLinkAlert(
                        url: urlText,
                        duplicate: duplicate,
                        student: student,
                        topic: topic,
                        description: description,
                        pages: pages,
                        occurrence: occurrence
                    )
                    return
                }
                createLesson(student: student,
                             topic: topic,
                             description: description,
                             pages: pages,
                             urlText: urlText,
                             occurrence: occurrence)
            }
        )
        present(alert, animated: true)
    }
    
    private func showDuplicateLinkAlert(
        url: String,
        duplicate: Lesson,
        student: User,
        topic: String,
        description: String,
        pages: String,
        occurrence: LessonOccurrence?
    ) {
        let dateString = formatter.lessonDateString(for: duplicate)
        let alert = UIAlertController(
            title: "link_already_used".localized,
            message: String(format: "duplicate_source_warning".localized,
                            duplicate.studentName,
                            dateString),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "cancel".localized,
                                      style: .cancel))
        alert.addAction(UIAlertAction(title: "add_anyway".localized,
                                      style: .default) { [weak self] _ in
            self?.createLesson(
                student: student,
                topic: topic,
                description: description,
                pages: pages,
                urlText: url,
                occurrence: occurrence
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
        alert.addAction(UIAlertAction(title: "all_students".localized,
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
        alert.addAction(UIAlertAction(title: "cancel".localized,
                                      style: .cancel))
        present(alert, animated: true)
    }
    
    func showEditLesson(lesson: Lesson) {
        let alert = UIAlertController(
            title: "edit_lesson".localized,
            message: lesson.studentName,
            preferredStyle: .alert
        )
        alert.addTextField {
            $0.placeholder = "topic".localized
            $0.text = lesson.topic
        }
        alert.addTextField {
            $0.placeholder = "description".localized
            $0.text = lesson.bookTitle
        }
        alert.addTextField {
            $0.placeholder = "pages".localized
            $0.text = lesson.pages
        }
        alert.addTextField {
            $0.placeholder = "source_URL".localized
            $0.text = lesson.sourceLinks.first?.url ?? ""
        }
        alert.addAction(UIAlertAction(title: "cancel".localized,
                                      style: .cancel))
        alert.addAction(UIAlertAction(title: "save".localized,
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

extension TeacherLessonsViewController {
    private func showScheduleOptions(for student: User) {
        let schedules = viewModel.schedules(for: student.id)
        router.showScheduleDetail(
            student: student,
            schedules: schedules,
            onAdd: { [weak self] draft, completion in
               guard let self,
                     let teacherId = viewModel.currentTeacherId else { return }
                let schedule = Schedule(studentId: draft.studentId,
                                        teacherId: teacherId,
                                        weekday: draft.weekday,
                                        time: draft.time,
                                        isActive: true,
                                        createdAt: Date())
                viewModel.saveSchedule(schedule, completion: completion)
            },
            onDelete: { [weak self] schedule in
                self?.viewModel.deleteSchedule(schedule)
            },
            onToggleAutoDebit: { [weak self] isEnabled in
                self?.viewModel.updateAutoDebit(for: student,
                                                isEnabled: isEnabled)
            }
        )
    }
}
