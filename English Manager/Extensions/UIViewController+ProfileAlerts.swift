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
        let alert = UIAlertController(title: "change_password".localized,
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addTextField {
            $0.placeholder = "new_password".localized
            $0.isSecureTextEntry = true
        }
        alert.addTextField {
            $0.placeholder = "confirm_password".localized
            $0.isSecureTextEntry = true
        }
        alert.addAction(UIAlertAction(title: "cancel".localized,
                                      style: .cancel))
        alert.addAction(UIAlertAction(title: "change".localized,
                                      style: .default) { [weak self] _ in
                guard let password = alert.textFields?[0].text,
                      let confirm = alert.textFields?[1].text,
                      !password.isEmpty else { return }
                guard password == confirm else {
                    self?.showAlert(
                        title: "Error",
                        message: "password_are_not_the_same".localized
                    )
                    return
                }
                onConfirm(password)
            })
        present(alert, animated: true)
    }

    func showSignOutAlert(onConfirm: @escaping () -> Void) {
        let alert = UIAlertController(title: "sign_out".localized,
                                      message: "are_you_sure".localized,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "cancel".localized,
                                      style: .cancel))
        alert.addAction(UIAlertAction(title: "sign_out".localized,
                                      style: .destructive) { _ in
                onConfirm()
            })
        present(alert, animated: true)
    }
}
