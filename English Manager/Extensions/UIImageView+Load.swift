//
//  UIImageView+Load.swift
//  English Manager
//
//  Created by Sergej Klepikov on 13.08.2026.
//

import UIKit
import Kingfisher

extension UIImageView {
    func loadImage(from urlString: String?,
                   placeholder: UIImage? = UIImage(systemName: "photo")) {
        guard let urlString,
              let url = URL(string: urlString) else {
            image = placeholder
            tintColor = .appTextSecondary
            return
        }
        kf.setImage(with: url, placeholder: placeholder)
    }
}
