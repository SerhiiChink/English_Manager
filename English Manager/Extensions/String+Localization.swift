//
//  String+Localization.swift
//  English Manager
//
//  Created by Sergej Klepikov on 11.04.2026.
//

import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
