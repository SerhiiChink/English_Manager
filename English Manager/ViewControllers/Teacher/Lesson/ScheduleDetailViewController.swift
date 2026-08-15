//
//  ScheduleDetailViewController.swift
//  English Manager
//
//  Created by Sergej Klepikov on 18.04.2026.
//

import UIKit
import SnapKit

final class ScheduleDetailViewController: UIViewController {
    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mainStack = UIStackView()
    private let schedulesCard = UIView()
    private let schedulesStack = UIStackView()
    private let emptyLabel = UILabel()
    private let rescheduledStack = UIStackView()
    private let addButton = UIButton(type: .system)
    
    // MARK: - Properties
    private let student: User
    private var schedules: [Schedule]
    private var rescheduledLessons: [RescheduledLesson]
    private let onAdd: (ScheduleDraft, @escaping (Schedule) -> Void) -> Void
    private let onDelete: (Schedule) -> Void
    private let onDeleteRescheduled: (String) -> Void
    private let scheduleFormatter: ScheduleFormatterProtocol = ScheduleFormatter()
    private let lessonFormatter: LessonFormatterProtocol = LessonFormatter()
    private let swipeAnimator: SwipeAnimatorProtocol = SwipeAnimator()
    
    // MARK: - Init
    init(student: User,
         schedules: [Schedule],
         rescheduledLessons: [RescheduledLesson],
         onAdd: @escaping (ScheduleDraft,
                           @escaping (Schedule) -> Void) -> Void,
         onDelete: @escaping (Schedule) -> Void,
         onDeleteRescheduled: @escaping (String) -> Void
    ) {
        self.student = student
        self.schedules = schedules
        self.rescheduledLessons = rescheduledLessons
        self.onAdd = onAdd
        self.onDelete = onDelete
        self.onDeleteRescheduled = onDeleteRescheduled
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
        reloadSchedules()
        setupRescheduledCard()
        reloadRescheduled()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .appBackground
        setupScrollView()
        setupMainStack()
        setupSchedulesCard()
        setupAddButton()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(80)
        }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
    }
    
    private func setupMainStack() {
        mainStack.axis = .vertical
        mainStack.spacing = 16
        contentView.addSubview(mainStack)
        mainStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
    
    private func setupSchedulesCard() {
        schedulesCard.styleAsCard()
        mainStack.addArrangedSubview(schedulesCard)
        let headerStack = makeCardHeader(
            icon: "calendar.badge.clock",
            iconColor: .appAccent,
            title: "schedule".localized
        )
        schedulesCard.addSubview(headerStack)
        headerStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.left.equalToSuperview().offset(16)
        }
        emptyLabel.text = "no_schedule_yet".localized
        emptyLabel.font = .systemFont(ofSize: 14)
        emptyLabel.textColor = .appTextSecondary
        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true
        schedulesCard.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints {
            $0.top.equalTo(headerStack.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(44)
        }
        schedulesStack.axis = .vertical
        schedulesStack.spacing = 0
        schedulesCard.addSubview(schedulesStack)
        schedulesStack.snp.makeConstraints {
            $0.top.equalTo(headerStack.snp.bottom).offset(8)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-8)
        }
    }
 
    private func setupRescheduledCard() {
        let card = UIView()
        card.styleAsCard()
        card.isHidden = rescheduledLessons.isEmpty
        mainStack.addArrangedSubview(card)
        let headerStack = makeCardHeader(
            icon: "clock.badge.exclamationmark",
            iconColor: .appRed,
            title: "rescheduled_lessons".localized
        )
        card.addSubview(headerStack)
        headerStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.left.equalToSuperview().offset(16)
        }
        rescheduledStack.axis = .vertical
        rescheduledStack.spacing = 0
        card.addSubview(rescheduledStack)
        rescheduledStack.snp.makeConstraints {
            $0.top.equalTo(headerStack.snp.bottom).offset(8)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-8)
        }
    }
    
    private func setupAddButton() {
        var config = UIButton.Configuration.filled()
        config.title = "add_schedule".localized
        config.image = UIImage(systemName: "plus.circle.fill")
        config.imagePadding = 6
        config.baseBackgroundColor = .appAccent
        config.baseForegroundColor = .white
        config.cornerStyle = .fixed
        addButton.configuration = config
        addButton.layer.cornerRadius = Layout.cornerRadius
        addButton.addAction(UIAction { [weak self] _ in
            self?.showSchedulePicker()
        }, for: .touchUpInside)
        view.addSubview(addButton)
        addButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-26)
            $0.height.equalTo(Layout.buttonHeight)
        }
    }
    
    private func setupNavigationBar() {
        let name = student.fullName.isEmpty
        ? student.displayName
        : student.fullName
        title = name
        navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Reload
    private func reloadSchedules() {
        schedulesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if schedules.isEmpty {
            emptyLabel.isHidden = false
            schedulesStack.isHidden = true
        } else {
            emptyLabel.isHidden = true
            schedulesStack.isHidden = false
            schedules.enumerated().forEach { index, schedule in
                schedulesStack.addArrangedSubview(makeRow(
                    iconName: "clock",
                    iconColor: .appAccent,
                    text: scheduleFormatter.formatted(schedule, timezone: nil),
                    tag: index,
                    swipeAction: #selector(handleScheduleSwipe(_:))
                ))
                if index < schedules.count - 1 {
                    schedulesStack.addArrangedSubview(DividerView())
                }
            }
        }
    }
    
    private func reloadRescheduled() {
        rescheduledStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        rescheduledStack.superview?.isHidden = rescheduledLessons.isEmpty
        rescheduledLessons.enumerated().forEach { index, lesson in
            rescheduledStack.addArrangedSubview(makeRow(
                iconName: "clock",
                iconColor: .appAccent,
                text: lessonFormatter.occurrenceDateString(for: lesson.scheduledAt),
                tag: index,
                swipeAction: #selector(handleRescheduledSwipe(_:))
            ))
            if index < rescheduledLessons.count - 1 {
                rescheduledStack.addArrangedSubview(DividerView())
            }
        }
    }

    // MARK: - Private
    private func makeCardHeader(icon: String,
                                iconColor: UIColor,
                                title: String) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = iconColor
        iconView.contentMode = .scaleAspectFit
        iconView.snp.makeConstraints { $0.width.height.equalTo(20) }
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .appText
        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(label)
        return stack
    }
    
    private func makeRow(iconName: String,
                         iconColor: UIColor,
                         text: String,
                         tag: Int,
                         swipeAction: Selector) -> UIView {
        let container = UIView()
        container.backgroundColor = .appSurface
        container.layer.cornerRadius = Layout.cornerRadius
        container.tag = tag
        container.isUserInteractionEnabled = true
        let icon = UIImageView(image: UIImage(systemName: iconName))
        icon.tintColor = iconColor
        icon.contentMode = .scaleAspectFit
        container.addSubview(icon)
        icon.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(16)
        }
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 15)
        label.textColor = .appText
        container.addSubview(label)
        label.snp.makeConstraints {
            $0.left.equalTo(icon.snp.right).offset(10)
            $0.right.equalToSuperview().inset(40)
            $0.top.bottom.equalToSuperview().inset(14)
        }
        let trashIcon = UIImageView(image: UIImage(systemName: "trash"))
        trashIcon.tintColor = .appRed
        trashIcon.alpha = 0.3
        trashIcon.contentMode = .scaleAspectFit
        container.addSubview(trashIcon)
        trashIcon.snp.makeConstraints {
            $0.right.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(16)
        }
        let swipe = UISwipeGestureRecognizer(target: self, action: swipeAction)
        swipe.direction = .left
        container.addGestureRecognizer(swipe)
        return container
    }
    
    // MARK: - Actions
    @objc private func handleScheduleSwipe(_ gesture: UISwipeGestureRecognizer) {
        guard let container = gesture.view else { return }
        let index = container.tag
        guard index < schedules.count else { return }
        let schedule = schedules[index]
        swipeAnimator.swipeLeft(on: container) { [weak self] in
            self?.showDeleteScheduleAlert(for: schedule, view: container)
        }
    }
    
    @objc private func handleRescheduledSwipe(_ gesture: UISwipeGestureRecognizer) {
        guard let container = gesture.view else { return }
        let index = container.tag
        guard index < rescheduledLessons.count else { return }
        let lesson = rescheduledLessons[index]
        swipeAnimator.swipeLeft(on: container) { [weak self] in
            self?.showDeleteRescheduledAlert(lesson: lesson,
                                             view: container)
        }
    }
}

// MARK: - Alerts
extension ScheduleDetailViewController {
    private func showDeleteScheduleAlert(for schedule: Schedule, view: UIView) {
        let alert = UIAlertController(
            title: "delete_schedule".localized,
            message: scheduleFormatter.formatted(schedule, timezone: nil),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "cancel".localized,
                                      style: .cancel) { [weak self] _ in
            self?.swipeAnimator.snapBack(view)
        })
        alert.addAction(UIAlertAction(
            title: "delete".localized,
            style: .destructive
        ) { [weak self] _ in
                guard let self else { return }
                onDelete(schedule)
                schedules.removeAll() { $0.id == schedule.id }
                reloadSchedules()
            }
        )
        present(alert, animated: true)
    }
    
    
    private func showDeleteRescheduledAlert(lesson: RescheduledLesson,
                                            view: UIView) {
        let alert = UIAlertController(
            title: "delete_rescheduled".localized,
            message: lessonFormatter.occurrenceDateString(for: lesson.scheduledAt),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "cancel".localized,
                                      style: .cancel) { [weak self] _ in
                self?.swipeAnimator.snapBack(view)
            })
        alert.addAction(UIAlertAction(
            title: "delete".localized,
            style: .destructive
        ) { [weak self] _ in
            guard let self else { return }
            onDeleteRescheduled(lesson.id)
            rescheduledLessons.removeAll { $0.id == lesson.id }
            reloadRescheduled()
        })
        present(alert, animated: true)
    }
    
    private func showSchedulePicker() {
        let vc = SchedulePickerViewController(
            student: student
        ) { [weak self] draft in
            self?.onAdd(draft) { savedSchedule in
                self?.schedules.append(savedSchedule)
                self?.reloadSchedules()
            }
        }
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        present(vc, animated: true)
    }
}
