//
//  UIViewController+NavigationBar.swift
//  English Manager
//
//  Created by Sergej Klepikov on 16.05.2026.
//

import UIKit

extension UIViewController {
    func setupProfileNavigationBar() {
        navigationItem.title = "profile".localized
        navigationController?.isNavigationBarHidden = false
    }
}
