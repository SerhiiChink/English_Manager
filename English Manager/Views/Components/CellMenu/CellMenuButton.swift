//
//  CellMenuButton.swift
//  English Manager
//
//  Created by Sergej Klepikov on 19.04.2026.
//

import UIKit
import SnapKit

final class CellMenuButton: UIButton {
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setup() {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "ellipsis")
        config.baseBackgroundColor = .appTextSecondary
        config.contentInsets = NSDirectionalEdgeInsets(top: 8,
                                                       leading: 8,
                                                       bottom: 8,
                                                       trailing: 8)
        self.configuration = config
        self.showsMenuAsPrimaryAction = true
    }
    
    // MARK: - Configure
    func configure(actions: [CellMenuAction]) {
        menu = UIMenu(children: actions.map { makeAction($0) })
    }
    
    // MARK: - Private
    private func makeAction(_ action: CellMenuAction) -> UIAction {
        UIAction(
            title: action.title,
            image: UIImage(systemName: action.icon),
            attributes: action.isDestructive ? .destructive : []
        ) { _ in
            action.handle()
        }
    }
}
