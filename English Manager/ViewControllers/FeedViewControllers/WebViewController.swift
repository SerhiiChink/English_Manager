//
//  WebViewController.swift
//  English Manager
//
//  Created by Sergej Klepikov on 13.08.2026.
//

import UIKit
import WebKit
import SnapKit

final class WebViewController: UIViewController {
    // MARK: - UI
    private let webView = WKWebView()
    private let progressView = UIProgressView(progressViewStyle: .bar)
    
    // MARK: - Properties
    private let url: String
    private let itemTitle: String
    private var item: RSSItem
    private let bookmarkService: BookmarkServiceProtocol
    private var isBookmarked: Bool
    private var progressObserver: NSKeyValueObservation?
    
    // MARK: - Init
    init(
        item: RSSItem,
        bookmarkService: BookmarkServiceProtocol = BookmarkService()
    ) {
        self.item = item
        self.url = item.link
        self.itemTitle = item.title
        self.bookmarkService = bookmarkService
        self.isBookmarked = bookmarkService.isBookmarked(item)
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
        setupProgressObserver()
        loadPage()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        progressObserver?.invalidate()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .appBackground
        setupProgressView()
        setupWebView()
    }
    
    private func setupProgressView() {
        progressView.tintColor = .appAccent
        progressView.trackTintColor = .clear
        view.addSubview(progressView)
        progressView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(2)
        }
    }
    
    private func setupWebView() {
        view.addSubview(webView)
        webView.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func setupNavigationBar() {
        navigationItem.title = item.source
        navigationItem.largeTitleDisplayMode = .never
        updateBookmarkButton()
    }
    
    // MARK: - Load
    private func loadPage() {
        guard let url = URL(string: url) else { return }
        webView.load(URLRequest(url: url))
    }
    
    // MARK: - Progress
    private func setupProgressObserver() {
        progressObserver = webView.observe(\.estimatedProgress,
                                            options: .new) { [weak self] webView, _ in
            guard let self else { return }
            let progress = Float(webView.estimatedProgress)
            progressView.setProgress(progress, animated: true)
            progressView.isHidden = progress >= 1.0
        }
    }
    
    // MARK: - Bookmark
    private func updateBookmarkButton() {
        let icon = isBookmarked 
            ? "bookmark.fill"
            : "bookmark"
        let tint: UIColor = isBookmarked
            ? .appAccent
            : .appTextSecondary
        let button = UIBarButtonItem(
            image: UIImage(systemName: icon),
            style: .plain,
            target: self,
            action: #selector(bookmarkTapped)
        )
        button.tintColor = tint
        navigationItem.rightBarButtonItem = button
    }
    
    private func toggleBookmark() {
        if isBookmarked {
            bookmarkService.remove(item)
        } else {
            bookmarkService.add(item)
        }
        isBookmarked.toggle()
        item.isBookmarked = isBookmarked
        updateBookmarkButton()
    }
    
    // MARK: - Actions
    @objc private func bookmarkTapped() {
        toggleBookmark()
    }
}
