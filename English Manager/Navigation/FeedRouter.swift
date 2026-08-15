//
//  FeedRouter.swift
//  English Manager
//
//  Created by Sergej Klepikov on 14.08.2026.
//

import UIKit

protocol FeedRouterProtocol: AnyObject {
    func showWeb(item: RSSItem)
    func showBookmarks()
}

final class FeedRouter: FeedRouterProtocol {
    // MARK: - Properties
    private weak var navigationController: UINavigationController?

    // MARK: - Init
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }

    // MARK: - Navigation
    func showWeb(item: RSSItem) {
        let vc = WebViewController(item: item)
        navigationController?.pushViewController(vc, animated: true)
    }

    func showBookmarks() {
        let vc = BookmarksViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
