//
//  BookmarksViewController.swift
//  English Manager
//
//  Created by Sergej Klepikov on 13.08.2026.
//

import UIKit
import SnapKit

final class BookmarksViewController: UIViewController {
    // MARK: - UI
    private let collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero,
                                  collectionViewLayout: .feedLayout())
        cv.backgroundColor = .appBackground
        cv.register(FeedCell.self,
                    forCellWithReuseIdentifier: FeedCell.reuseId)
        return cv
    }()
    private let emptyStateView = EmptyStateView(
        icon: "bookmark",
        title: "no_bookmarks_yet".localized,
        subtitle: "bookmark_hint".localized
    )
    
    // MARK: - Properties
    private let viewModel: BookmarksViewModelProtocol
    
    // MARK: - Init
    init(viewModel: BookmarksViewModelProtocol = BookmarksViewModel()) {
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchBookmarks()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .appBackground
        setupCollectionView()
        setupEmptyState()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
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
    
    private func setupNavigationBar() {
        title = "bookmarks".localized
        navigationItem.largeTitleDisplayMode = .never
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            self?.reloadData()
        }
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
extension BookmarksViewController: UICollectionViewDataSource {
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
            self?.viewModel.removeBookmark(item)
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension BookmarksViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let item = viewModel.items[indexPath.item]
        let vc = WebViewController(item: item)
        navigationController?.pushViewController(vc, animated: true)
    }
}
