//
//  BookmarksViewModelTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 15.09.2026.
//

import XCTest
@testable import English_Manager

@MainActor
final class BookmarksViewModelTests: XCTestCase {
    // MARK: - Properties
    private var sut: BookmarksViewModel!
    private var mockBookmarkService: MockBookmarkService!

    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        mockBookmarkService = MockBookmarkService()
        sut = BookmarksViewModel(bookmarkService: mockBookmarkService)
    }

    override func tearDown() {
        sut = nil
        mockBookmarkService = nil
        super.tearDown()
    }

    // MARK: - Helpers
    private func makeItem(
        title: String = "Test Title",
        link: String = "https://example.com/item1",
        isBookmarked: Bool = true
    ) -> RSSItem {
        RSSItem(
            title: title,
            link: link,
            description: "Test Description",
            imageURL: nil,
            audioURL: nil,
            pubDate: Date(),
            source: "TED-Ed",
            isBookmarked: isBookmarked
        )
    }

    // MARK: - Fetch Tests
    func testFetchBookmarksLoadsItemsFromServiceAndTriggersOnUpdate() {
        let item1 = makeItem(title: "Item 1", link: "https://example.com/1")
        let item2 = makeItem(title: "Item 2", link: "https://example.com/2")
        mockBookmarkService.add(item1)
        mockBookmarkService.add(item2)
        var updateCalled = false
        sut.onUpdate = { updateCalled = true }
        sut.fetchBookmarks()
        XCTAssertTrue(updateCalled)
        XCTAssertEqual(sut.items.count, 2)
    }

    // MARK: - Remove Tests
    func testRemoveBookmarkRemovesItemFromServiceAndArrayAndTriggersOnUpdate() {
        let item1 = makeItem(title: "Item 1", link: "https://example.com/1")
        let item2 = makeItem(title: "Item 2", link: "https://example.com/2")
        mockBookmarkService.add(item1)
        mockBookmarkService.add(item2)
        sut.fetchBookmarks()
        XCTAssertEqual(sut.items.count, 2)
        var updateCalled = false
        sut.onUpdate = { updateCalled = true }
        sut.removeBookmark(item1)
        XCTAssertTrue(updateCalled)
        XCTAssertEqual(sut.items.count, 1)
        XCTAssertEqual(sut.items.first?.link, item2.link)
        XCTAssertFalse(mockBookmarkService.isBookmarked(item1))
    }
}
