//
//  AvatarView.swift
//  English Manager
//
//  Created by Sergej Klepikov on 20.03.2026.
//

import UIKit
import SnapKit
import Kingfisher

final class AvatarView: UIView {
    // MARK: - UI
    private let imageView = UIImageView()
    private let initialsLabel = UILabel()
    private let badgeView = UIView()
    
    // MARK: - Callbacks
    var onTap: (() -> Void)?
    
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
        imageView.layer.cornerRadius = bounds.width / 2
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        setupImageView()
        setupInitialisLabel()
        setupBadgeView()
        setupTap()
    }
    
    private func setupImageView() {
        imageView.backgroundColor = .appAccent
        imageView.layer.cornerRadius = 40
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupInitialisLabel() {
        initialsLabel.font = .systemFont(ofSize: 32, weight: .semibold)
        initialsLabel.textColor = .white
        initialsLabel.textAlignment = .center
        imageView.addSubview(initialsLabel)
        initialsLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    private func setupBadgeView() {
        badgeView.backgroundColor = .appAccent
        badgeView.layer.cornerRadius = 10
        badgeView.layer.borderWidth = 2
        badgeView.layer.borderColor = UIColor.appBackground.cgColor
        addSubview(badgeView)
        badgeView.snp.makeConstraints {
            $0.width.height.equalTo(20)
            $0.bottom.right.equalToSuperview()
        }
        let plusLabel = UILabel()
        plusLabel.text = "+"
        plusLabel.font = .systemFont(ofSize: 14, weight: .bold)
        plusLabel.textColor = .white
        plusLabel.textAlignment = .center
        badgeView.addSubview(plusLabel)
        plusLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    private func setupTap() {
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(tapped)
        ))
    }
    
    // MARK: - Load Image
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        imageView.kf.setImage(
            with: url,
            options: [
                .cacheOriginalImage,
                .diskCacheExpiration(.days(7)),
                .memoryCacheExpiration(.seconds(300))
            ]
        ) { [weak self] result in
            switch result {
            case .success:
                self?.initialsLabel.isHidden = true
            case .failure:
                self?.initialsLabel.isHidden = false
            }
        }
    }
    
    // MARK: - Configure
    func configure(name: String, surname: String?, email: String) {
        reset()
        let initials = [name.first, surname?.first]
            .compactMap { $0 }
            .map { String($0).uppercased() }
            .joined()
        initialsLabel.text = initials.isEmpty
            ? String(email.prefix(1)).uppercased()
            : initials
    }
    
    // MARK: - Public
    func setImage(_ image: UIImage) {
        imageView.image = image
        initialsLabel.isHidden = true
    }
    
    func showBadge(_ show: Bool) {
        badgeView.isHidden = !show
    }
    
    func reset() {
        imageView.image = nil
        initialsLabel.isHidden = false
    }
    
    // MARK: - Actions
    @objc private func tapped() {
        onTap?()
    }
}
