//
//  UIViewController+ProfileAlerts.swift
//  English Manager
//
//  Created by Sergej Klepikov on 21.03.2026.
//

import UIKit
import SnapKit

extension UIViewController {
    func showChangePasswordAlert(
        onConfirm: @escaping (String) -> Void
    ) {
        let alert = UIAlertController(title: "Change Password",
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addTextField {
            $0.placeholder = "New Password"
            $0.isSecureTextEntry = true
        }
        alert.addTextField {
            $0.placeholder = "Confirm Password"
            $0.isSecureTextEntry = true
        }
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel))
        alert.addAction(UIAlertAction(title: "Change",
                                      style: .default) { [weak self] _ in
                guard let password = alert.textFields?[0].text,
                      let confirm = alert.textFields?[1].text,
                      !password.isEmpty else { return }
                guard password == confirm else {
                    self?.showAlert(title: "Error",
                                    message: "Passwords do not match")
                    return
                }
                onConfirm(password)
            })
        present(alert, animated: true)
    }

    func showSignOutAlert(onConfirm: @escaping () -> Void) {
        let alert = UIAlertController(title: "Sign Out",
                                      message: "Are you sure?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel))
        alert.addAction(UIAlertAction(title: "Sign Out",
                                      style: .destructive) { _ in
                onConfirm()
            })
        present(alert, animated: true)
    }
}
