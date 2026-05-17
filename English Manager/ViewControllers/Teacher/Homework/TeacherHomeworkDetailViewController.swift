//
//  TeacherHomeworkDetailViewController.swift
//  English Manager
//
//  Created by Sergej Klepikov on 31.03.2026.
//

import UIKit
import SnapKit
import SafariServices

final class TeacherHomeworkDetailViewController: UIViewController {
    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let homeworkCard = UIView()
    private let studentLabel = UILabel()
    private let dateLabel = UILabel()
    private let titleLabel = UILabel()
    private let descriptionTitleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let linkButton = UIButton(type: .system)
    private let statusBadge = UIView()
    private let statusLabel = UILabel()
    private let reviewCard = UIView()
    private let feedbackTitleLabel = UILabel()
    private let feedbackLabel = UILabel()
    private let gradeLabel = UILabel()
    private let reviewButton = UIButton(type: .system)
    
    // MARK: - Properties
    private var homework: Homework
    private let onReview: (Homework, Int, String) -> Void
    private let formatter: HomeworkFormatterProtocol = HomeworkFormatter()
    
    // MARK: - Init
    init(homework: Homework,
         onReview: @escaping (Homework, Int, String) -> Void) {
        self.homework = homework
        self.onReview = onReview
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
        configure()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .appBackground
        title = "Homework Detail"
        setupScrollView()
        setupHomeworkCard()
        setupReviewCard()
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
    
    // MARK: - Homework Card
    private func setupHomeworkCard() {
        homeworkCard.styleAsCard()
        contentView.addSubview(homeworkCard)
        homeworkCard.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.left.right.equalToSuperview().inset(Layout.padding)
        }
        setupStatusBadge()
        setupStudentLabel()
        setupDateLabel()
        setupTitleLabel()
        setupDescriptionSection()
        setupLinkButton()
    }
    
    private func setupStatusBadge() {
        statusBadge.layer.cornerRadius = 8
        homeworkCard.addSubview(statusBadge)
        statusBadge.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.right.equalToSuperview().inset(16)
            $0.height.equalTo(20)
            $0.width.greaterThanOrEqualTo(60)
        }
        statusLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        statusLabel.textColor = .white
        statusBadge.addSubview(statusLabel)
        statusLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.right.equalToSuperview().inset(8)
        }
    }
    
    private func setupStudentLabel() {
        studentLabel.font = .systemFont(ofSize: 14, weight: .medium)
        studentLabel.textColor = .appTextSecondary
        homeworkCard.addSubview(studentLabel)
        studentLabel.snp.makeConstraints {
            $0.centerY.equalTo(statusBadge)
            $0.left.equalToSuperview().inset(16)
        }
    }
    
    private func setupDateLabel() {
        dateLabel.font = .systemFont(ofSize: 13)
        dateLabel.textColor = .appTextSecondary
        homeworkCard.addSubview(dateLabel)
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(statusBadge.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().inset(16)
        }
    }
    
    private func setupTitleLabel() {
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .appText
        titleLabel.numberOfLines = 0
        homeworkCard.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().inset(16)
        }
    }
    
    private func setupDescriptionSection() {
        descriptionTitleLabel.text = "Description"
        descriptionTitleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        descriptionTitleLabel.textColor = .appTextSecondary
        homeworkCard.addSubview(descriptionTitleLabel)
        descriptionTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(16)
        }
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.textColor = .appText
        descriptionLabel.numberOfLines = 0
        homeworkCard.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionTitleLabel.snp.bottom).offset(4)
            $0.left.right.equalToSuperview().inset(16)
        }
    }
    
    private func setupLinkButton() {
        linkButton.setTitleColor(.appAccent, for: .normal)
        linkButton.titleLabel?.font = .systemFont(ofSize: 15)
        linkButton.contentHorizontalAlignment = .left
        linkButton.addAction(UIAction { [weak self] _ in
            guard let url = self?.homework.sourceLink else { return }
            self?.openLink(url)
        }, for: .touchUpInside)
        homeworkCard.addSubview(linkButton)
        linkButton.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(12)
            $0.left.right.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
    
    // MARK: - Review Card
    private func setupReviewCard() {
        reviewCard.styleAsCard()
        contentView.addSubview(reviewCard)
        reviewCard.snp.makeConstraints {
            $0.top.equalTo(homeworkCard.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.bottom.equalToSuperview().offset(-32)
        }
        setupFeedbackSection()
        setupReviewButton()
    }
    
    private func setupFeedbackSection() {
        feedbackTitleLabel.text = "Teacher Feedback"
        feedbackTitleLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        feedbackTitleLabel.textColor = .appTextSecondary
        reviewCard.addSubview(feedbackTitleLabel)
        feedbackTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.left.right.equalToSuperview().inset(16)
        }
        gradeLabel.font = .systemFont(ofSize: 32, weight: .bold)
        gradeLabel.textColor = .appAccent
        gradeLabel.textAlignment = .center
        reviewCard.addSubview(gradeLabel)
        gradeLabel.snp.makeConstraints {
            $0.top.equalTo(feedbackTitleLabel.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().inset(16)
        }
        feedbackLabel.font = .systemFont(ofSize: 15)
        feedbackLabel.textColor = .appText
        feedbackLabel.numberOfLines = 0
        reviewCard.addSubview(feedbackLabel)
        feedbackLabel.snp.makeConstraints {
            $0.top.equalTo(gradeLabel.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().inset(16)
        }
    }
    
    private func setupReviewButton() {
        reviewButton.backgroundColor = .appAccent
        reviewButton.setTitleColor(.white, for: .normal)
        reviewButton.titleLabel?.font = .systemFont(ofSize: 16,
                                                    weight: .semibold)
        reviewButton.layer.cornerRadius = Layout.cornerRadius
        reviewButton.addAction(UIAction { [weak self] _ in
            self?.showReviewAlert()
        }, for: .touchUpInside)
        reviewCard.addSubview(reviewButton)
        reviewButton.snp.makeConstraints {
            $0.top.equalTo(feedbackLabel.snp.bottom).offset(24)
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(Layout.buttonHeight)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
    
    // MARK: - Configure
    private func configure() {
        studentLabel.text = homework.studentName
        dateLabel.text = formatter.createdDateString(homework)
        titleLabel.text = homework.title
        descriptionLabel.text = homework.description.isEmpty
            ? "No description"
            : homework.description
        if homework.sourceLink.isEmpty {
            linkButton.isHidden = true
        } else {
            linkButton.setTitle("🔗 \(homework.sourceLink)", for: .normal)
        }
        switch homework.status {
        case .pending:
            statusBadge.backgroundColor = .appGold
            statusLabel.text = "Pending"
            feedbackTitleLabel.isHidden = true
            feedbackLabel.isHidden = true
            gradeLabel.isHidden = true
            reviewButton.setTitle("Write Review", for: .normal)
        case .reviewed, .seen:
            statusBadge.backgroundColor = homework.status == .reviewed
                ? .appGreen
                : .appTextSecondary
            statusLabel.text = homework.grade.map { 
                "Grade: \($0)/10" } ?? "Reviewed"
            gradeLabel.text = homework.grade.map { "\($0)/10" }
            feedbackLabel.text = homework.teacherFeedback ?? "No feedback"
            reviewButton.setTitle("Edit Review", for: .normal)
        }
    }
    
    // MARK: - Alert
    private func showReviewAlert() {
        let alert = UIAlertController(title: "Review Homework",
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addTextField {
            $0.placeholder = "Grade (1-10)"
            $0.keyboardType = .numberPad
            $0.text = self.homework.grade.map { String($0) }
        }
        alert.addTextField {
            $0.placeholder = "Feedback (optional)"
            $0.text = self.homework.teacherFeedback
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(
            title: "Save",
            style: .default) { [weak self] _ in
                guard let self,
                      let gradeText = alert.textFields?[0].text,
                      let grade = Int(gradeText),
                      (1...10).contains(grade) else {
                    self?.showAlert(title: "Invalide grade",
                                    message: "Enter a numder from 1 to 10")
                    return
                }
                let feedback = alert.textFields?[1].text ?? ""
                onReview(homework, grade, feedback)
                navigationController?.popViewController(animated: true)
            }
        )
        present(alert, animated: true)
    }
    
    // MARK: - Private
    private func openLink(_ urlString: String) {
        var urlStr = urlString
        if !urlStr.hasPrefix("http") { urlStr = "https://\(urlStr)" }
        guard let url = URL(string: urlStr) else { return }
        present(SFSafariViewController(url: url), animated: true)
    }
}
