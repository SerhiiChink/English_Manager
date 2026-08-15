//
//  BookmarksViewModel.swift
//  English Manager
//
//  Created by Sergej Klepikov on 13.08.2026.
//

import Foundation

protocol BookmarksViewModelProtocol: AnyObject {
    var onUpdate: (() -> Void)? { get set }
    var items: [RSSItem] { get }
    func fetchBookmarks()
    func removeBookmark(_ item: RSSItem)
}

final class BookmarksViewModel: BookmarksViewModelProtocol {
    // MARK: - Callbacks
    var onUpdate: (() -> Void)?
    
    // MARK: - Data
    private(set) var items: [RSSItem] = []
    
    // MARK: - Properties
    private let bookmarkService: BookmarkServiceProtocol
    
    // MARK: - Init
    init(bookmarkService: BookmarkServiceProtocol = BookmarkService()) {
        self.bookmarkService = bookmarkService
    }
    
    // MARK: - Fetch
    func fetchBookmarks() {
        items = bookmarkService.fetchAll()
        onUpdate?()
    }
    
    // MARK: - Remove
    func removeBookmark(_ item: RSSItem) {
        bookmarkService.remove(item)
        items.removeAll { $0.link == item.link }
        onUpdate?()
    }
}
