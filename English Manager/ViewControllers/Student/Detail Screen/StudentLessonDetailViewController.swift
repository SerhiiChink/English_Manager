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
    private let contentView = UIView()
    private let dateLabel = UILabel()
    private let topicLabel = UILabel()
    private let bookLabel = UILabel()
    private let pageLabel = UILabel()
    private let linksStackView = UIStackView()
    private let linkTitleLabel = UILabel()
    
    // MARK: - Properties
    private let lesson: Lesson
    private let formatter: LessonFormatterProtocol = LessonFormatter()
    
    // MARK: - Init
    init(lesson: Lesson) {
        self.lesson = lesson
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
        title = "Lesson Detail"
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        setupDateLabel()
        setupTopicLabel()
        setupBookLabel()
        setupPageLabel()
        setupLinksSection()
    }
    
    private func setupDateLabel() {
        dateLabel.font = .systemFont(ofSize: 14, weight: .medium)
        dateLabel.textColor = .appTextSecondary
        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.left.right.equalToSuperview().inset(Layout.padding)
        }
    }
    
    private func setupTopicLabel() {
        topicLabel.font = .systemFont(ofSize: 22, weight: .bold)
        topicLabel.textColor = .appText
        topicLabel.numberOfLines = 0
        contentView.addSubview(topicLabel)
        topicLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().inset(Layout.padding)
        }
    }
    
    private func setupBookLabel() {
        bookLabel.font = .systemFont(ofSize: 16)
        bookLabel.textColor = .appText
        bookLabel.numberOfLines = 0
        contentView.addSubview(bookLabel)
        bookLabel.snp.makeConstraints {
            $0.top.equalTo(topicLabel.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(Layout.padding)
        }
    }
    
    private func setupPageLabel() {
        pageLabel.font = .systemFont(ofSize: 16)
        pageLabel.textColor = .appTextSecondary
        contentView.addSubview(pageLabel)
        pageLabel.snp.makeConstraints {
            $0.top.equalTo(bookLabel.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().inset(Layout.padding)
        }
    }
    
    private func setupLinksSection() {
        linkTitleLabel.text = "Materials"
        linkTitleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        linkTitleLabel.textColor = .appText
        contentView.addSubview(linkTitleLabel)
        linkTitleLabel.snp.makeConstraints {
            $0.top.equalTo(pageLabel.snp.bottom).offset(24)
            $0.left.right.equalToSuperview().inset(Layout.padding)
        }
        linksStackView.axis = .vertical
        linksStackView.spacing = 12
        contentView.addSubview(linksStackView)
        linksStackView.snp.makeConstraints {
            $0.top.equalTo(linkTitleLabel.snp.bottom).offset(12)
            $0.left.right.equalToSuperview().inset(Layout.padding)
            $0.bottom.equalToSuperview().offset(-24)
        }
    }
        
    // MARK: - Configure
    private func configure() {
        dateLabel.text = formatter.detailDateString(for: lesson)
        topicLabel.text = lesson.topic
        bookLabel.text = "Book \(lesson.bookTitle)"
        pageLabel.text = "Page: \(lesson.pages)"
        if lesson.sourceLinks.isEmpty {
            linkTitleLabel.isHidden = true
        } else {
            lesson.sourceLinks.forEach { link in
                let button = UIButton(type: .system)
                button.setTitle(
                    link.title.isEmpty
                        ? link.url
                        : link.title,
                    for: .normal
                )
                button.setTitleColor(.appAccent, for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: 15)
                button.contentHorizontalAlignment = .left
                button.addAction(UIAction { [weak self] _ in
                    self?.openLink(link.url)
                }, for: .touchUpInside)
                linksStackView.addArrangedSubview(button)
            }
        }
    }
    
    
    // MARK: - Private
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

