//
//  FeedDateFormatter.swift
//  English Manager
//
//  Created by Sergej Klepikov on 13.08.2026.
//

import Foundation

protocol FeedDateFormatterProtocol {
    func relativeString(from date: Date) -> String
}

final class FeedDateFormatter: FeedDateFormatterProtocol {
    // MARK: - Properties
    private let formatter: RelativeDateTimeFormatter = {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f
    }()
    
    // MARK: - Public
    func relativeString(from date: Date) -> String {
        formatter.localizedString(for: date, relativeTo: Date())
    }
}
