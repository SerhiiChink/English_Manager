//
//  TeacherBannerView.swift
//  English Manager
//
//  Created by Sergej Klepikov on 28.06.2026.
//

import UIKit
import SnapKit

final class TeacherBannerView: UIView {
    // MARK: - UI
    private let avatarView = AvatarView()
    private let subtitleLabel = UILabel()
    private let nameLabel = UILabel()
    private let emptyLabel = UILabel()
    private let teacherStack = UIStackView()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup
    private func setupUI() {
        styleAsCard(.bordered)
        setupTeacherStack()
        setupEmptyLabel()
    }
    
    private func setupTeacherStack() {
        avatarView.showBadge(false)
        avatarView.snp.makeConstraints {
            $0.width.height.equalTo(44)
        }
        subtitleLabel.text = "your_teacher".localized
        subtitleLabel.font = .systemFont(ofSize: 11)
        subtitleLabel.textColor = .appTextSecondary
        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = .appText
        let labelStack = UIStackView(arrangedSubviews: [subtitleLabel,
                                                        nameLabel])
        labelStack.axis = .vertical
        labelStack.spacing = 2
        teacherStack.axis = .horizontal
        teacherStack.spacing = 12
        teacherStack.alignment = .center
        teacherStack.addArrangedSubview(avatarView)
        teacherStack.addArrangedSubview(labelStack)
        addSubview(teacherStack)
        teacherStack.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(14)
            $0.left.right.equalToSuperview().inset(16)
        }
    }
    
    private func setupEmptyLabel() {
        emptyLabel.text = "no_teacher_yet".localized
        emptyLabel.font = .systemFont(ofSize: 14)
        emptyLabel.textColor = .appTextSecondary
        emptyLabel.textAlignment = .center
        addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(16)
        }
    }
    
    // MARK: - Configure
    func configure(teacher: User?) {
        let hasTeacher = teacher != nil
        teacherStack.isHidden = !hasTeacher
        emptyLabel.isHidden = hasTeacher
        guard let teacher else { return }
        avatarView.configure(name: teacher.name,
                             surname: teacher.surname,
                             email: teacher.email)
        if let photoURL = teacher.photoURL {
            avatarView.loadImage(from: photoURL)
        }
        nameLabel.text = teacher.fullName.isEmpty
            ? teacher.email
            : teacher.fullName
    }
}
