//
//  UIScrollView+Refresh.swift
//  English Manager
//
//  Created by Sergej Klepikov on 20.03.2026.
//

import UIKit

extension UIScrollView {
    func addRefreshControl(target: Any?,
                           action: Selector) {
        let refresh = UIRefreshControl()
        refresh.addTarget(target, action: action, for: .valueChanged)
        refreshControl = refresh
    }

    func endRefreshing() {
        refreshControl?.endRefreshing()
    }
}
