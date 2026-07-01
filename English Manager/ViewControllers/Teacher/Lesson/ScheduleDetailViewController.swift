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
    private let schedulesCard = UIView()
    private let schedulesStack = UIStackView()
    private let emptyLabel = UILabel()
    private let autoDebitCard = UIView()
    private let autoDebitTitle = UILabel()
    private let autoDebitSubtitle = UILabel()
    private let autoDebitToggle = UISwitch()
    private let addButton = UIButton(type: .system)
    
    // MARK: - Properties
    private let student: User
    private var schedules: [Schedule]
    private let onAdd: (ScheduleDraft, @escaping (Schedule) -> Void) -> Void
    private let onDelete: (Schedule) -> Void
    private let onToggleAutoDebit: (Bool) -> Void
    private let formatter: ScheduleFormatterProtocol = ScheduleFormatter()
    private let swipeAnimator: SwipeAnimatorProtocol = SwipeAnimator()
    
    // MARK: - Init
    init(student: User,
         schedules: [Schedule],
         onAdd: @escaping (ScheduleDraft,
                           @escaping (Schedule) -> Void) -> Void,
         onDelete: @escaping (Schedule) -> Void,
         onToggleAutoDebit: @escaping (Bool) -> Void) {
        self.student = student
        self.schedules = schedules
        self.onAdd = onAdd
        self.onDelete = onDelete
        self.onToggleAutoDebit = onToggleAutoDebit
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
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .appBackground
        setupScrollView()
        setupSchedulesCard()
        setupAutoDebitCard()
        setupAddButton()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
    }
    
    private func setupSchedulesCard() {
        schedulesCard.styleAsCard()
        contentView.addSubview(schedulesCard)
        schedulesCard.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.left.right.equalToSuperview().inset(Layout.padding)
        }
        
        let headerStack = UIStackView()
        headerStack.axis = .horizontal
        headerStack.spacing = 8
        headerStack.alignment = .center
        let icon = UIImageView(image: UIImage(systemName: "calendar.badge.clock"))
        icon.tintColor = .appAccent
        icon.contentMode = .scaleAspectFit
        icon.snp.makeConstraints {
            $0.width.height.equalTo(20)
        }
        
        let cardTitle = UILabel()
        cardTitle.text = "schedule".localized
        cardTitle.font = .systemFont(ofSize: 15, weight: .semibold)
        cardTitle.textColor = .appText
        headerStack.addArrangedSubview(icon)
        headerStack.addArrangedSubview(cardTitle)
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
    
    private func setupAutoDebitCard() {
        autoDebitCard.styleAsCard()
        contentView.addSubview(autoDebitCard)
        autoDebitCard.snp.makeConstraints {
            $0.top.equalTo(schedulesCard.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        autoDebitTitle.text = "auto_debit".localized
        autoDebitTitle.font = .systemFont(ofSize: 15, weight: .semibold)
        autoDebitTitle.textColor = .appText
        autoDebitCard.addSubview(autoDebitTitle)
        autoDebitTitle.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.left.equalToSuperview().offset(16)
        }
        
        autoDebitToggle.onTintColor = .appAccent
        autoDebitToggle.isOn = student.isAutoDebitEnabled ?? false
        autoDebitToggle.addTarget(self,
                                  action: #selector(toggleChanged),
                                  for: .valueChanged)
        autoDebitCard.addSubview(autoDebitToggle)
        autoDebitToggle.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().inset(16)
        }
        
        autoDebitSubtitle.text = "auto_debit_description".localized
        autoDebitSubtitle.font = .systemFont(ofSize: 12)
        autoDebitSubtitle.numberOfLines = 2
        autoDebitCard.addSubview(autoDebitSubtitle)
        autoDebitSubtitle.snp.makeConstraints {
            $0.top.equalTo(autoDebitTitle.snp.bottom).offset(4)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalTo(autoDebitToggle.snp.left).offset(-12)
            $0.bottom.equalToSuperview().offset(-16)
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
                let row = makeScheduleRow(schedule: schedule)
                schedulesStack.addArrangedSubview(row)
                if index < schedules.count - 1 {
                    let separator = UIView()
                    separator.backgroundColor = .appBackground
                    schedulesStack.addArrangedSubview(separator)
                    separator.snp.makeConstraints {
                        $0.height.equalTo(1)
                    }
                }
            }
        }
    }
    
    // MARK: - Private
    private func makeScheduleRow(schedule: Schedule) -> UIView {
        let container = UIView()
        container.backgroundColor = .appSurface
        container.tag = schedules.firstIndex(
            where: { $0.id == schedule.id }) ?? 0
        container.isUserInteractionEnabled = true
        let icon = UIImageView(image: UIImage(systemName: "clock"))
        icon.tintColor = .appAccent
        icon.contentMode = .scaleAspectFit
        container.addSubview(icon)
        icon.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(16)
        }
        let label = UILabel()
        label.text = formatter.formatted(schedule, timezone: nil)
        label.font = .systemFont(ofSize: 15)
        label.textColor = .appText
        container.addSubview(label)
        label.snp.makeConstraints {
            $0.left.equalTo(icon.snp.right).offset(10)
            $0.right.equalToSuperview().inset(16)
            $0.top.bottom.equalToSuperview().inset(14)
        }
        let swipeHint = UIImageView(image: UIImage(systemName: "trash"))
        swipeHint.tintColor = .appRed
        swipeHint.alpha = 0.3
        swipeHint.contentMode = .scaleAspectFit
        container.addSubview(swipeHint)
        swipeHint.snp.makeConstraints {
            $0.right.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(16)
        }
        
        let swipe = UISwipeGestureRecognizer(target: self,
                                             action: #selector(handleSwipe(_:)))
        swipe.direction = .left
        container.addGestureRecognizer(swipe)
        return container
    }
    
    // MARK: - Actions
    @objc private func toggleChanged() {
        onToggleAutoDebit(autoDebitToggle.isOn)
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        guard let container = gesture.view else { return }
        let index = container.tag
        guard index < schedules.count else { return }
        let schedule = schedules[index]
        swipeAnimator.swipeLeft(on: container) { [weak self] in
            self?.showDeleteConfirmation(for: schedule, view: container)
        }
    }
}

// MARK: - Alerts
extension ScheduleDetailViewController {
    private func showDeleteConfirmation(for schedule: Schedule, view: UIView) {
        let alert = UIAlertController(
            title: "delete_schedule".localized,
            message: formatter.formatted(schedule, timezone: nil),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "cancel".localized,
                                      style: .cancel) { [weak self] _ in
            self?.swipeAnimator.snapBack(view)
        })
        alert.addAction(UIAlertAction(
            title: "delete".localized,
            style: .destructive) { [weak self] _ in
                guard let self else { return }
                onDelete(schedule)
                schedules.removeAll() { $0.id == schedule.id }
                reloadSchedules()
            }
        )
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
