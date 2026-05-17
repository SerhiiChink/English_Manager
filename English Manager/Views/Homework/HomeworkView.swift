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
    private let emptyLabel = UILabel()
    
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
        setupEmptyLabel()
    }
    
    private func setupCollectionView() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        collectionView.addRefreshControl(target: self,
                                         action: #selector(refreshTapped))
    }
    
    private func setupEmptyLabel() {
        emptyLabel.text = "No homework yet"
        emptyLabel.textColor = .appTextSecondary
        emptyLabel.font = .systemFont(ofSize: 16)
        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true
        addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
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
        emptyLabel.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
        collectionView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func refreshTapped() {
        onRefresh?()
    }
}
