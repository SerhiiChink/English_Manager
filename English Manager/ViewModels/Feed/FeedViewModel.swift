//
//  FeedViewModel.swift
//  English Manager
//
//  Created by Sergej Klepikov on 13.08.2026.
//

import Foundation

protocol FeedViewModelProtocol: AnyObject {
    var onUpdate: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var onLoading: ((Bool) -> Void)? { get set }
    var items: [RSSItem] { get }
    var selectedChannel: RSSChannel { get }
    func fetchItems()
    func selectChannel(_ channel: RSSChannel)
    func toggleBookmark(for item: RSSItem)
    func isBookmarked(_ item: RSSItem) -> Bool
}

final class FeedViewModel: FeedViewModelProtocol {
    // MARK: - Callbacks
    var onUpdate: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoading: ((Bool) -> Void)?
    
    // MARK: - Data
    private(set) var items: [RSSItem] = []
    private(set) var selectedChannel: RSSChannel = RSSChannel.allCases.first ?? .tedEd
    private var isFetching = false
    
    // MARK: - Properties
    private let rssService: RSSServiceProtocol
    private let bookmarkService: BookmarkServiceProtocol
    
    // MARK: - Init
    init(
        rssService: RSSServiceProtocol = RSSService(),
        bookmarkService: BookmarkServiceProtocol = BookmarkService()
    ) {
        self.rssService = rssService
        self.bookmarkService = bookmarkService
    }
    
    // MARK: - Fetch
    func fetchItems() {
        guard !isFetching else { return }
        isFetching = true
        onLoading?(true)
        Task {
            do {
                let fetched = try await rssService.fetchItems(from: selectedChannel)
                let bookmarks = bookmarkService.fetchAll()
                let merged = fetched.map { item -> RSSItem in
                    var copy = item
                    copy.isBookmarked = bookmarks.contains { $0.link == item.link }
                    return copy
                }
                await MainActor.run { [weak self] in
                    self?.items = merged
                    self?.isFetching = false
                    self?.onLoading?(false)
                    self?.onUpdate?()
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.isFetching = false
                    self?.onLoading?(false)
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Channel
    func selectChannel(_ channel: RSSChannel) {
        guard channel != selectedChannel else { return }
        selectedChannel = channel
        items = []
        onUpdate?()
        fetchItems()
    }
    
    // MARK: - Bookmarks
    func toggleBookmark(for item: RSSItem) {
        if bookmarkService.isBookmarked(item) {
            bookmarkService.remove(item)
        } else {
            bookmarkService.add(item)
        }
        if let index = items.firstIndex(where: { $0.link == item.link }) {
            items[index].isBookmarked = !item.isBookmarked
        }
        onUpdate?()
    }
    
    func isBookmarked(_ item: RSSItem) -> Bool {
        bookmarkService.isBookmarked(item)
    }
}
