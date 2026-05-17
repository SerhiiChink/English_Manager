//
//  StudentLessonDetailViewController.swift
//  English Manager
//
//  Created by Sergej Klepikov on 16.03.2026.
//

import UIKit
import SnapKit
import SafariServices

final class StudentLessonDetailViewController: UIViewController {
    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let lessonsCard = UIView()
    private let lessonCardStack = UIStackView()
    private let dateLabel = UILabel()
    private let topicLabel = UILabel()
    private let statusBadge = UIView()
    private let statusLabel = UILabel()
    private let materialsCard = UIView()
    private let descriptionTitleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let divider = UIView()
    private let linksStack = UIStackView()
    private let linksTitleLabel = UILabel()
    private let teacherLabel = UILabel()
    
    // MARK: - Properties
    private let lesson: Lesson
    private let teacherName: String?
    private let formatter: LessonFormatterProtocol = LessonFormatter()
    
    // MARK: - Init
    init(lesson: Lesson,
         teacherName: String? = nil) {
        self.lesson = lesson
        self.teacherName = teacherName
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
        title = "lesson_detail".localized
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        scrollView.addSubview(contentStack)
        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 16,
                                                           left: 16,
                                                           bottom: 32,
                                                           right: 16))
            $0.width.equalToSuperview().offset(-32)
        }
        setupLessonCard()
        setupMaterialsCard()
        setupTeacherLabel()
    }
    
    private func setupLessonCard() {
        lessonsCard.styleAsCard()
        contentStack.addArrangedSubview(lessonsCard)
        lessonCardStack.axis = .vertical
        lessonCardStack.spacing = 12
        lessonCardStack.layoutMargins = UIEdgeInsets(
            top: 16, left: 16, bottom: 16, right: 16
        )
        lessonCardStack.isLayoutMarginsRelativeArrangement = true
        lessonsCard.addSubview(lessonCardStack)
        lessonCardStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        let topRow = UIStackView()
        topRow.axis = .horizontal
        topRow.spacing = 8
        topRow.alignment = .top
        topRow.addArrangedSubview(topicLabel)
        topRow.addArrangedSubview(dateLabel)
        dateLabel.setContentHuggingPriority(.required, for: .horizontal)
        dateLabel.setContentCompressionResistancePriority(.required,
                                                          for: .horizontal)
        lessonCardStack.addArrangedSubview(topRow)
        lessonCardStack.addArrangedSubview(statusBadge)
        topicLabel.font = .systemFont(ofSize: 22, weight: .bold)
        topicLabel.textColor = .appText
        topicLabel.numberOfLines = 0
        dateLabel.font = .systemFont(ofSize: 13, weight: .medium)
        dateLabel.textColor = .appTextSecondary
        dateLabel.textAlignment = .right
        statusBadge.layer.cornerRadius = 8
        statusBadge.layer.cornerRadius = Layout.cornerRadius
        statusBadge.layer.maskedCorners = [.layerMinXMaxYCorner,
                                           .layerMaxXMaxYCorner]
        statusBadge.isHidden = true
        statusBadge.snp.makeConstraints {
            $0.height.equalTo(24)
        }
        statusLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        statusLabel.textColor = .white
        statusLabel.textAlignment = .center
        statusBadge.addSubview(statusLabel)
        statusLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.right.equalToSuperview().inset(10)
        }
    }
    
    private func setupMaterialsCard() {
        materialsCard.styleAsCard()
        contentStack.addArrangedSubview(materialsCard)
        descriptionTitleLabel.text = "description".localized
        descriptionTitleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        descriptionTitleLabel.textColor = .appTextSecondary
        materialsCard.addSubview(descriptionTitleLabel)
        descriptionTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.left.right.equalToSuperview().inset(16)
        }
        descriptionLabel.font = .systemFont(ofSize: 15)
        descriptionLabel.textColor = .appText
        descriptionLabel.numberOfLines = 0
        materialsCard.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionTitleLabel.snp.bottom).offset(4)
            $0.left.right.equalToSuperview().inset(16)
        }
        divider.backgroundColor = .appBackground
        materialsCard.addSubview(divider)
        divider.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(1)
        }
        linksTitleLabel.text = "materials".localized
        linksTitleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        linksTitleLabel.textColor = .appText
        materialsCard.addSubview(linksTitleLabel)
        linksTitleLabel.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom).offset(12)
            $0.left.right.equalToSuperview().inset(16)
        }
        linksStack.axis = .vertical
        linksStack.spacing = 8
        materialsCard.addSubview(linksStack)
        linksStack.snp.makeConstraints {
            $0.top.equalTo(linksTitleLabel.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
    
    private func setupTeacherLabel() {
        teacherLabel.font = .systemFont(ofSize: 13, weight: .light)
        teacherLabel.textColor = .appTextSecondary
        teacherLabel.textAlignment = .center
        let icon = UIImage(systemName: "person.fill")?
            .withTintColor(.appTextSecondary, renderingMode: .alwaysOriginal)
        let attachment = NSTextAttachment(image: icon ?? UIImage())
        attachment.bounds = CGRect(x: 0, y: -2, width: 14, height: 14)
        teacherLabel.attributedText = NSAttributedString(attachment: attachment)
        contentStack.addArrangedSubview(teacherLabel)
    }
    
    private func makeLinkButton(for link: SourceLink) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "link")
        config.imagePadding = 6
        config.baseForegroundColor = .appAccent
        config.contentInsets = .zero
        let bnt = UIButton(configuration: config)
        bnt.contentHorizontalAlignment = .left
        bnt.addAction(UIAction { [weak self] _ in
            self?.openLink(link.url)
        }, for: .touchUpInside)
        return bnt
    }
        
    // MARK: - Configure
    private func configure() {
        dateLabel.text = formatter.detailDateString(for: lesson)
        topicLabel.text = lesson.topic
        let description = [lesson.bookTitle, lesson.pages]
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
        descriptionLabel.text = description.isEmpty
            ? "-"
            : description
        configureStatus()
        configureLinks()
        configureTeacher()
    }
    
    
    // MARK: - Private
    private func configureStatus() {
        let style = OccurrenceStatusMapper.style(for: lesson,
                                                 formatter: formatter)
        statusBadge.isHidden = false
        statusBadge.backgroundColor = style.color
        statusLabel.text = style.text
    }
    
    private func configureLinks() {
        linksStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard !lesson.sourceLinks.isEmpty else {
            linksTitleLabel.isHidden = true
            divider.isHidden = true
            let label = UILabel()
            label.text = "no_materials".localized
            label.font = .systemFont(ofSize: 14)
            label.textColor = .appTextSecondary
            linksStack.addArrangedSubview(label)
            return
        }
        lesson.sourceLinks.forEach { link in
            let bnt = makeLinkButton(for: link)
            let title = link.title.isEmpty
                ? link.url
                : link.title
            var config = bnt.configuration
            config?.attributedTitle = AttributedString(
                title,
                attributes: .init([.font: UIFont.systemFont(ofSize: 15)])
                )
            bnt.configuration = config
            linksStack.addArrangedSubview(bnt)
        }
    }
    
    private func configureTeacher() {
        guard let name = teacherName, !name.isEmpty else {
            teacherLabel.isHidden = true
            return
        }
        let existing = teacherLabel.attributedText.map {
            NSMutableAttributedString(attributedString: $0)
        } ?? NSMutableAttributedString()
        existing.append(NSAttributedString(string: " \(name)"))
        teacherLabel.attributedText = existing
    }
    
    private func openLink(_ urlString: String) {
        var urlStr = urlString
        if !urlStr.hasPrefix("http") {
            urlStr = "https://\(urlStr)"
        }
        guard let url = URL(string: urlStr) else { return }
        let safatiVC = SFSafariViewController(url: url)
        present(safatiVC, animated: true)
    }
}

