//
//  RSSItem.swift
//  English Manager
//
//  Created by Sergej Klepikov on 13.08.2026.
//

import Foundation

struct RSSItem: Codable {
    let title: String
    let link: String
    let description: String?
    let imageURL: String?
    let audioURL: String?
    let pubDate: Date?
    let source: String
    
    var isBookmarked: Bool = false
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case title, link, description, imageURL, audioURL, pubDate, source, isBookmarked
    }
}
