//
//  RSSError.swift
//  English Manager
//
//  Created by Sergej Klepikov on 13.08.2026.
//

import Foundation

enum RSSError: LocalizedError {
    case invalidURL
    case parsingFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:    return "Invalid RSS URL"
        case .parsingFailed: return "Failed to parse RSS feed"
        }
    }
}
