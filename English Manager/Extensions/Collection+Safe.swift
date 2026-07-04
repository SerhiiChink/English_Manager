//
//  Collection+Safe.swift
//  English Manager
//
//  Created by Sergej Klepikov on 14.05.2026.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
