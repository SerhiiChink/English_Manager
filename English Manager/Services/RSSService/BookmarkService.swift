//
//  BookmarkService.swift
//  English Manager
//
//  Created by Sergej Klepikov on 13.08.2026.
//

import Foundation

protocol BookmarkServiceProtocol {
    func add(_ item: RSSItem)
    func remove(_ item: RSSItem)
    func isBookmarked(_ item: RSSItem) -> Bool
    func fetchAll() -> [RSSItem]
}

final class BookmarkService: BookmarkServiceProtocol {
    // MARK: - Properties
    private let key = "bookmarked_rss_items"
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    // MARK: - Add
    func add(_ item: RSSItem) {
        var items = fetchAll()
        guard !items.contains(where: { $0.link == item.link }) else { return }
        var bookmarked = item
        bookmarked.isBookmarked = true
        items.insert(bookmarked, at: 0)
        save(items)
    }
    
    // MARK: - Remove
    func remove(_ item: RSSItem) {
        var items = fetchAll()
        items.removeAll { $0.link == item.link }
        save(items)
    }
    
    // MARK: - Check
    func isBookmarked(_ item: RSSItem) -> Bool {
        fetchAll().contains { $0.link == item.link }
    }
    
    // MARK: - Fetch
    func fetchAll() -> [RSSItem] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let items = try? decoder.decode([RSSItem].self, from: data)
        else { return [] }
        return items
    }
    
    // MARK: - Private
    private func save(_ items: [RSSItem]) {
        guard let data = try? encoder.encode(items) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}

