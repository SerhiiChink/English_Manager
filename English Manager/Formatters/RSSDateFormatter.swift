//
//  RSSDateFormatter.swift
//  English Manager
//
//  Created by Sergej Klepikov on 13.08.2026.
//

import Foundation

protocol RSSDateFormatterProtocol {
    func date(from string: String) -> Date?
}

final class RSSDateFormatter: RSSDateFormatterProtocol {
    // MARK: - Properties
    private let formatter = DateFormatter()
    private let formats = [
        "EEE, dd MMM yyyy HH:mm:ss Z",
        "yyyy-MM-dd'T'HH:mm:ssZ",
        "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
    ]
    
    // MARK: - Public
    func date(from string: String) -> Date? {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        for format in formats {
            f.dateFormat = format
            if let date = f.date(from: string) { return date }
        }
        return nil
    }
}
