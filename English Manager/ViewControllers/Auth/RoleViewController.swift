//
//  RoleViewController.swift
//  English Manager
//
//  Created by Sergej Klepikov on 06.03.2026.
//

import UIKit
import SnapKit

final class RoleViewController: UIViewController {
    // MARK: - UI
    private let titleLabel = UILabel()
    private let teacherButton = UIButton(type: .system)
    private let studentButton = UIButton(type: .system)
    
    // MARK: - Properties
    private weak var router: AuthRouterProtocol?
    
    // MARK: - Init
    init(
        router: AuthRouterProtocol
    ) {
        self.router = router
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
        setupTeacherButton()
        setupStudentButton()
    }
    
    private func setupTitleLabel() {
        titleLabel.text = "Choose your role" /// localization
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .appText
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(80)
        }
    }
    
    private func setupTeacherButton() {
        teacherButton.setTitle("Teacher", for: .normal)
        teacherButton.setTitleColor(.white, for: .normal)
        teacherButton.backgroundColor = .appAccent
        teacherButton.layer.cornerRadius = Layout.cornerRadius
        teacherButton.addTarget(self,
                                action: #selector(teacherButtonTapped),
                                for: .touchUpInside)
        view.addSubview(teacherButton)
        teacherButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(48)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.height.equalTo(Layout.buttonHeight)
        }
    }
    
    private func setupStudentButton() {
        studentButton.setTitle("Student", for: .normal)
        studentButton.setTitleColor(.appAccent, for: .normal)
        studentButton.backgroundColor = .appSurface
        studentButton.layer.cornerRadius = Layout.cornerRadius
        studentButton.addTarget(self,
                                action: #selector(studentButtonTapped),
                                for: .touchUpInside)
        view.addSubview(studentButton)
        studentButton.snp.makeConstraints {
            $0.top.equalTo(teacherButton.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.height.equalTo(Layout.buttonHeight)
        }
    }
    
    // MARK: - Actions
    @objc private func teacherButtonTapped() {
        UserDefaults.standard.set(UserRole.teacher.rawValue,
                                  forKey: UDKeys.userRole)
        router?.showMainScreen(role: .teacher)
    }
    
    @objc private func studentButtonTapped() {
        UserDefaults.standard.set(UserRole.student.rawValue,
                                  forKey: UDKeys.userRole)
        router?.showMainScreen(role: .student)
    }
}

