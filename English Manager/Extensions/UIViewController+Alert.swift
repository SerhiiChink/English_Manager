//
//  UIViewController+Alert.swift
//  English Manager
//
//  Created by Sergej Klepikov on 14.03.2026.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String? = nil) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .default))
        present(alert, animated: true)
    }
    
    func showDeleteAccountAlert(onConfirm: @escaping (String,
                                                      String) -> Void) {
        let alert = UIAlertController(
            title: "delete_account".localized,
            message: "delete_account_warning".localized,
            preferredStyle: .alert
        )
        alert.addTextField {
            $0.placeholder = "email".localized
            $0.keyboardType = .emailAddress
            $0.autocapitalizationType = .none
        }
        alert.addTextField {
            $0.placeholder = "password".localized
            $0.isSecureTextEntry = true
        }
        alert.addAction(UIAlertAction(title: "cancel".localized,
                                      style: .cancel))
        alert.addAction(UIAlertAction(
            title: "delete".localized,
            style: .destructive) { [weak self] _ in
                guard let email = alert.textFields?[0].text,
                      let password = alert.textFields?[1].text else { return }
                let validatir = ValidationService()
                if case .failure(let message) = validatir.validateLoginForm(
                    email: email,
                    password: password
                ) {
                    self?.showAlert(title: "error".localized,
                                    message: message)
                    return
                }
                onConfirm(email, password)
            }
        )
        present(alert, animated: true)
    }
}
