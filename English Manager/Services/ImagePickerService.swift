//
//  ImagePickerService.swift
//  English Manager
//
//  Created by Sergej Klepikov on 20.03.2026.
//

import UIKit
import PhotosUI

final class ImagePickerService: NSObject {
    // MARK: - Callbacks
    var onImagePicked: ((UIImage) -> Void)?
    
    // MARK: - Show
    func show(from viewController: UIViewController) {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        viewController.present(picker, animated: true)
    }
}

    // MARK: - PHPickerViewControllerDelegate
extension ImagePickerService: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController,
                didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let result = results.first else { return }
        result.itemProvider.loadObject(
            ofClass: UIImage.self) { [weak self] object, _ in
                guard let image = object as? UIImage else { return }
                DispatchQueue.main.async {
                    self?.onImagePicked?(image)
                }
            }
    }
}
