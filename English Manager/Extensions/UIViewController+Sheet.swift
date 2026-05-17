//
//  UIViewController+Sheet.swift
//  English Manager
//
//  Created by Sergej Klepikov on 07.05.2026.
//

import UIKit

extension UIViewController {
    func presentAsSheet(
        _ vc: UIViewController,
        detent: UISheetPresentationController.Detent = .medium()) {
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [detent]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        present(vc, animated: true)
    }
}
