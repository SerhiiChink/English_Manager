//
//  RSSItem+Mock.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 15.08.2026.
//

import Foundation
@testable import English_Manager

extension RSSItem {
    static func mock(
        title: String = "Test Title",
        link: String = "https://example.com/test",
        description: String? = "Test description text",
        imageURL: String? = "https://example.com/image.jpg",
        audioURL: String? = nil,
        pubDate: Date? = Date(),
        source: String = "TED-Ed",
        isBookmarked: Bool = false
    ) -> RSSItem {
        RSSItem(
            title: title,
            link: link,
            description: description,
            imageURL: imageURL,
            audioURL: audioURL,
            pubDate: pubDate,
            source: source,
            isBookmarked: isBookmarked
        )
    }
}
