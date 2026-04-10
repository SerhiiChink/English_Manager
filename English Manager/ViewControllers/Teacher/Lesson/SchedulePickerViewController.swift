//
//  SchedulePickerViewController.swift
//  English Manager
//
//  Created by Sergej Klepikov on 05.04.2026.
//

import UIKit
import SnapKit

final class SchedulePickerViewController: UIViewController {
    
    // MARK: - UI
    private let titleLabel = UILabel()
    private let dayPicker = UIPickerView()
    private let timePicker = UIDatePicker()
    private let saveButton = UIButton(type: .system)
    
    // MARK: - Properties
    private let student: User
    private let onSave: (ScheduleDraft) -> Void
    private let formatter: ScheduleFormatterProtocol = ScheduleFormatter()
    private let days = [
        "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
    ]
    
    // MARK: - Init
    init(student: User,
         onSave: @escaping (ScheduleDraft) -> Void) {
        self.student = student
        self.onSave = onSave
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
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .appBackground
        setupTitleLabel()
        setupDayPicker()
        setupSaveButton()
        setupTimePicker()
    }
    
    private func setupTitleLabel() {
        titleLabel.text = "Schedule for \(student.displayName)"
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.left.right.equalToSuperview().inset(Layout.padding)
        }
    }
    
    private func setupDayPicker() {
        dayPicker.dataSource = self
        dayPicker.delegate = self
        view.addSubview(dayPicker)
        dayPicker.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.height.equalTo(140)
        }
    }
    
    private func setupTimePicker() {
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        view.addSubview(timePicker)
        timePicker.snp.makeConstraints {
            $0.top.equalTo(dayPicker.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.height.equalTo(160)
            $0.bottom.lessThanOrEqualTo(saveButton.snp.top).offset(-16)
        }
    }
    
    private func setupSaveButton() {
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = .appAccent
        saveButton.layer.cornerRadius = Layout.cornerRadius
        saveButton.addTarget(self,
                             action: #selector(saveTapped),
                             for: .touchUpInside)
        view.addSubview(saveButton)
        saveButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.height.equalTo(Layout.buttonHeight)
        }
    }
    
    // MARK: - Actions
    @objc private func saveTapped() {
        let selectedDay = dayPicker.selectedRow(inComponent: 0)
        let weekday = selectedDay == 6 ? 1 : selectedDay + 2
        let time = formatter.timeString(from: timePicker.date)
        let draft = ScheduleDraft(studentId: student.id,
                                  weekday: weekday,
                                  time: time)
        onSave(draft)
        dismiss(animated: true)
    }
}

// MARK: - UIPickerViewDataSource
extension SchedulePickerViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        days.count
    }
}

// MARK: - UIPickerViewDelegate
extension SchedulePickerViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        days[row]
    }
}
