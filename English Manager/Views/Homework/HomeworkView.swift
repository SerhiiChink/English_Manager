//
//  HomeworkView.swift
//  English Manager
//
//  Created by Sergej Klepikov on 30.03.2026.
//

import UIKit
import SnapKit

final class HomeworkView: UIView {
    // MARK: - UI
    private let collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero,
                                  collectionViewLayout: .homeworkLayout())
        cv.backgroundColor = .appBackground
        cv.register(HomeworkCell.self,
                    forCellWithReuseIdentifier: HomeworkCell.reuseId)
        return cv
    }()
    
    // MARK: - Callbacks
    var onRefresh: (() -> Void)?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .appBackground
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        collectionView.addRefreshControl(target: self,
                                         action: #selector(refreshTapped))
    }
    
    // MARK: - Configure
    func setDataSource(_ dataSource: UICollectionViewDataSource) {
        collectionView.dataSource = dataSource
    }
    
    func setDelegate(_ delegate: UICollectionViewDelegate) {
        collectionView.delegate = delegate
    }
    
    func endRefreshing() {
        collectionView.endRefreshing()
    }
    
    func reloadData(isEmpty: Bool) {
        collectionView.endRefreshing()
        collectionView.isHidden = isEmpty
        collectionView.reloadData()
    }
    
    func deleteItem(at indexPath: IndexPath) {
        collectionView.performBatchUpdates {
            collectionView.deleteItems(at: [indexPath])
        }
    }
    
    // MARK: - Actions
    @objc private func refreshTapped() {
        onRefresh?()
    }
}
