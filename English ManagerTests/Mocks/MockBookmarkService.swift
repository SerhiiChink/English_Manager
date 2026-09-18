//
//  MockBookmarkService.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 15.08.2026.
//

import Foundation
@testable import English_Manager

final class MockBookmarkService: BookmarkServiceProtocol {
    // MARK: - Storage
    var storedItems: [RSSItem] = []
    
    // MARK: - Methods
    func add(_ item: RSSItem) {
        guard !storedItems.contains(where: { $0.link == item.link }) else { return }
        var bookmarked = item
        bookmarked.isBookmarked = true
        storedItems.insert(bookmarked, at: 0)
    }

    func remove(_ item: RSSItem) {
        storedItems.removeAll { $0.link == item.link }
    }

    func isBookmarked(_ item: RSSItem) -> Bool {
        storedItems.contains { $0.link == item.link }
    }

    func fetchAll() -> [RSSItem] {
        return storedItems
    }
}
