//
//  FeedViewController.swift
//  English Manager
//
//  Created by Sergej Klepikov on 13.08.2026.
//

import UIKit
import SnapKit

final class FeedViewController: UIViewController {
    // MARK: - UI
    private let collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero,
                                  collectionViewLayout: .feedLayout())
        cv.backgroundColor = .appBackground
        cv.register(FeedCell.self,
                    forCellWithReuseIdentifier: FeedCell.reuseId)
        return cv
    }()
    private let channelSelector = ChannelSelectorView()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let emptyStateView = EmptyStateView(
        icon: "newspaper",
        title: "no_feed_yet".localized,
        subtitle: "select_channel_hint".localized
    )
    
    // MARK: - Properties
    private let viewModel: FeedViewModelProtocol
    private let router: FeedRouterProtocol
    private let screenTitle: String
    
    // MARK: - Init
    init(
        router: FeedRouterProtocol,
        screenTitle: String = "learn".localized,
        viewModel: FeedViewModelProtocol = FeedViewModel()
    ) {
        self.router = router
        self.screenTitle = screenTitle
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
        viewModel.fetchItems()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .appBackground
        setupChannelSelector()
        setupCollectionView()
        setupEmptyState()
        setupActivityIndicator()
    }
    
    private func setupChannelSelector() {
        channelSelector.onSelect = { [weak self] channel in
            self?.viewModel.selectChannel(channel)
        }
        view.addSubview(channelSelector)
        channelSelector.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(40)
        }
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.addRefreshControl(target: self,
                                         action: #selector(refreshTapped))
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(channelSelector.snp.bottom).offset(8)
            $0.left.right.bottom.equalToSuperview()
        }
    }
    
    private func setupEmptyState() {
        view.addSubview(emptyStateView)
        emptyStateView.isHidden = true
        emptyStateView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.left.right.equalToSuperview().inset(32)
        }
    }
    
    private func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    private func setupNavigationBar() {
        title = screenTitle
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "bookmark"),
            style: .plain,
            target: self,
            action: #selector(bookmarksTapped)
        )
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            guard let self else { return }
            collectionView.endRefreshing()
            reloadData()
        }
        viewModel.onError = { [weak self] message in
            guard let self else { return }
            collectionView.endRefreshing()
            ToastView.show(.error(message), in: view)
        }
        viewModel.onLoading = { [weak self] isLoading in
            isLoading
            ? self?.activityIndicator.startAnimating()
            : self?.activityIndicator.stopAnimating()
        }
    }
    
    // MARK: - Actions
    @objc private func refreshTapped() {
        viewModel.fetchItems()
    }
    
    @objc private func bookmarksTapped() {
        router.showBookmarks()
    }
    
    // MARK: - Private
    private func reloadData() {
        let isEmpty = viewModel.items.isEmpty
        emptyStateView.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension FeedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        viewModel.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FeedCell.reuseId,
            for: indexPath) as! FeedCell
        let item = viewModel.items[indexPath.item]
        cell.configure(with: item)
        cell.onBookmark = { [weak self] in
            self?.viewModel.toggleBookmark(for: item)
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension FeedViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let item = viewModel.items[indexPath.item]
        router.showWeb(item: item)
    }
}
