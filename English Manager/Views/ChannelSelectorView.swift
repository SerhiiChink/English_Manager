//
//  ChannelSelectorView.swift
//  English Manager
//
//  Created by Sergej Klepikov on 13.08.2026.
//

import UIKit
import SnapKit

final class ChannelSelectorView: UIView {
    // MARK: - UI
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var buttons: [UIButton] = []

    // MARK: - Callbacks
    var onSelect: ((RSSChannel) -> Void)?

    // MARK: - Properties
    private var selectedChannel: RSSChannel = RSSChannel.allCases[0]

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        select(selectedChannel, animated: false)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup UI
    private func setupUI() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInset = UIEdgeInsets(top: 0,
                                               left: Layout.padding,
                                               bottom: 0,
                                               right: Layout.padding)
        addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(40)
        }
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }
        RSSChannel.allCases.forEach { channel in
            let button = makeChip(for: channel)
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
    }

    // MARK: - Private
    private func makeChip(for channel: RSSChannel) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = channel.shortName
        config.image = UIImage(systemName: channel.iconName)
        config.imagePadding = 6
        config.contentInsets = NSDirectionalEdgeInsets(top: 9,
                                                       leading: 14,
                                                       bottom: 9,
                                                       trailing: 14)
        config.preferredSymbolConfigurationForImage = .init(pointSize: 12)
        config.cornerStyle = .dynamic
        let button = UIButton(configuration: config)
        button.layer.cornerRadius = 19
        button.clipsToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        button.addAction(UIAction { [weak self] _ in
            self?.select(channel, animated: true)
            self?.onSelect?(channel)
        }, for: .touchUpInside)
        return button
    }

    private func select(_ channel: RSSChannel, animated: Bool) {
        selectedChannel = channel
        let update = {
            self.buttons.enumerated().forEach { index, button in
                let isSelected = RSSChannel.allCases[index] == channel
                var config = button.configuration
                config?.baseForegroundColor = isSelected
                    ? .appWhite
                    : .Brand.primary
                config?.background.backgroundColor = isSelected
                    ? .appAccent
                    : .appSurface
                config?.background.strokeColor = isSelected
                    ? .clear
                    : UIColor.appTextSecondary.withAlphaComponent(0.2)
                config?.background.strokeWidth = isSelected ? 0 : 0.5
                button.configuration = config
            }
        }
        animated
            ? UIView.animate(withDuration: 0.2, animations: update)
            : update()
    }
}
