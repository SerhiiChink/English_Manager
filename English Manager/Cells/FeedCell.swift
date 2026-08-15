//
//  FeedCell.swift
//  English Manager
//
//  Created by Sergej Klepikov on 13.08.2026.
//

import UIKit
import SnapKit
import Kingfisher

final class FeedCell: UICollectionViewCell {
    static let reuseId = "FeedCell"
    
    // MARK: - UI
    private let imageView = UIImageView()
    private let sourceLabel = UILabel()
    private let dateLabel = UILabel()
    private let titleLabel = UILabel()
    private let bookmarkButton = UIButton(type: .system)
    private let gradientLayer = CAGradientLayer()
    
    // MARK: - Callbacks
    var onBookmark: (() -> Void)?
    
    // MARK: - Properties
    private let dateFormatter: FeedDateFormatterProtocol = FeedDateFormatter()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = imageView.bounds
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        styleAsCard()
        clipsToBounds = true
        setupImageView()
        setupSourceLabel()
        setupBlurBar()
        setupBookmarkButton()
    }
    
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .Brand.surface
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupBlurBar() {
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 3
        dateLabel.font = .systemFont(ofSize: 11)
        dateLabel.textColor = .white.withAlphaComponent(0.75)
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        blur.clipsToBounds = true
        contentView.addSubview(blur)
        blur.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
        }
        blur.contentView.addSubview(titleLabel)
        blur.contentView.addSubview(dateLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.left.right.equalToSuperview().inset(14)
        }
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.left.equalToSuperview().offset(14)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }

    private func setupSourceLabel() {
        sourceLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        sourceLabel.textColor = .white.withAlphaComponent(0.8)
        contentView.addSubview(sourceLabel)
        sourceLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.left.equalToSuperview().offset(14)
        }
    }
    
    private func setupBookmarkButton() {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        blur.layer.cornerRadius = 18
        blur.clipsToBounds = true
        contentView.addSubview(blur)
        blur.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.right.equalToSuperview().inset(10)
            $0.width.height.equalTo(36)
        }
        bookmarkButton.tintColor = .appSurface
        bookmarkButton.addAction(UIAction { [weak self] _ in
            self?.onBookmark?()
        }, for: .touchUpInside)
        blur.contentView.addSubview(bookmarkButton)
        bookmarkButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // MARK: - Configure
    func configure(with item: RSSItem) {
        titleLabel.text = item.title
        sourceLabel.text = item.source
        dateLabel.text = item.pubDate.map {
            "· \(dateFormatter.relativeString(from: $0))"
        }
        updateBookmarkIcon(isBookmarked: item.isBookmarked)
        imageView.loadImage(from: item.imageURL)
    }
    
    // MARK: - Private
    private func updateBookmarkIcon(isBookmarked: Bool) {
        let icon = isBookmarked 
            ? "bookmark.fill"
            : "bookmark"
        bookmarkButton.setImage(UIImage(systemName: icon), for: .normal)
    }
}
