//
//  FeedViewModelTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 15.09.2026.
//

import XCTest
@testable import English_Manager

@MainActor
final class FeedViewModelTests: XCTestCase {
    // MARK: - Properties
    private var sut: FeedViewModel!
    private var mockRSSService: MockRSSService!
    private var mockBookmarkService: MockBookmarkService!

    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        mockRSSService = MockRSSService()
        mockBookmarkService = MockBookmarkService()
        sut = FeedViewModel(
            rssService: mockRSSService,
            bookmarkService: mockBookmarkService
        )
    }

    override func tearDown() {
        sut = nil
        mockRSSService = nil
        mockBookmarkService = nil
        super.tearDown()
    }

    // MARK: - Helpers
    private func makeItem(
        title: String = "Test Title",
        link: String = "https://example.com/item1",
        isBookmarked: Bool = false
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
    func testFetchItemsSuccessLoadsDataAndTriggersCallbacks() async {
        let item1 = makeItem(title: "Item 1", link: "https://example.com/1")
        let item2 = makeItem(title: "Item 2", link: "https://example.com/2")
        mockRSSService.resultToReturn = .success([item1, item2])
        var loadingStates: [Bool] = []
        let expUpdate = expectation(description: "Fetch completed")
        sut.onLoading = { loadingStates.append($0) }
        sut.onUpdate = { expUpdate.fulfill() }
        sut.fetchItems()
        await fulfillment(of: [expUpdate], timeout: 2.0)
        XCTAssertEqual(sut.items.count, 2)
        XCTAssertEqual(loadingStates, [true, false])
        XCTAssertEqual(mockRSSService.fetchedChannel, sut.selectedChannel)
    }

    func testFetchItemsMergesBookmarkStatesCorrectly() async {
        let bookmarkedItem = makeItem(title: "Item 1",
                                      link: "https://example.com/1")
        let regularItem = makeItem(title: "Item 2",
                                   link: "https://example.com/2")
        mockRSSService.resultToReturn = .success([bookmarkedItem, regularItem])
        mockBookmarkService.add(bookmarkedItem)
        let expUpdate = expectation(description: "Fetch completed")
        sut.onUpdate = { expUpdate.fulfill() }
        sut.fetchItems()
        await fulfillment(of: [expUpdate], timeout: 2.0)
        XCTAssertTrue(sut.items[0].isBookmarked)
        XCTAssertFalse(sut.items[1].isBookmarked)
    }

    func testFetchItemsWhenErrorOccursTriggersOnErrorCallback() async {
        let testError = NSError(
            domain: "TestError",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Failed to fetch RSS"]
        )
        mockRSSService.resultToReturn = .failure(testError)
        let expError = expectation(description: "Fetch error")
        var errorMessage: String?
        sut.onError = { error in
            errorMessage = error
            expError.fulfill()
        }
        sut.fetchItems()
        await fulfillment(of: [expError], timeout: 2.0)
        XCTAssertNotNil(errorMessage)
    }

    func testFetchItemsPreventsConcurrentRequests() async {
        mockRSSService.resultToReturn = .success([makeItem()])
        var updateCount = 0
        let exp = expectation(description: "Update called once")
        sut.onUpdate = {
            updateCount += 1
            exp.fulfill()
        }
        sut.fetchItems()
        sut.fetchItems()
        await fulfillment(of: [exp], timeout: 2.0)
        XCTAssertEqual(updateCount, 1)
    }

    // MARK: - Channel Selection Tests
    func testSelectChannelSameChannelDoesNothing() {
        let initialChannel = sut.selectedChannel
        var updateCalled = false
        sut.onUpdate = { updateCalled = true }
        sut.selectChannel(initialChannel)
        XCTAssertFalse(updateCalled)
    }

    func testSelectChannelDifferentChannelClearsItemsAndFetchesNew() async {
        guard RSSChannel.allCases.count >= 2 else { return }
        let firstChannel = RSSChannel.allCases[0]
        let secondChannel = RSSChannel.allCases[1]
        sut.selectChannel(firstChannel)
        let expUpdate = expectation(description: "Fetch completed for new channel")
        expUpdate.expectedFulfillmentCount = 2
        sut.onUpdate = { expUpdate.fulfill() }
        sut.selectChannel(secondChannel)
        await fulfillment(of: [expUpdate], timeout: 2.0)
        XCTAssertEqual(sut.selectedChannel, secondChannel)
        XCTAssertEqual(mockRSSService.fetchedChannel, secondChannel)
    }

    // MARK: - Bookmark Tests
    func testToggleBookmarkAddsBookmarkWhenNotBookmarked() async {
        let item = makeItem(link: "https://example.com/1",
                            isBookmarked: false)
        mockRSSService.resultToReturn = .success([item])
        let fetchExp = expectation(description: "Fetch completed")
        sut.onUpdate = { fetchExp.fulfill() }
        sut.fetchItems()
        await fulfillment(of: [fetchExp], timeout: 2.0)
        var updateCalled = false
        sut.onUpdate = { updateCalled = true }
        sut.toggleBookmark(for: item)
        XCTAssertTrue(updateCalled)
        XCTAssertTrue(sut.isBookmarked(item))
        XCTAssertTrue(sut.items.first?.isBookmarked == true)
    }

    func testToggleBookmarkRemovesBookmarkWhenAlreadyBookmarked() async {
        let item = makeItem(link: "https://example.com/1", isBookmarked: true)
        mockRSSService.resultToReturn = .success([item])
        mockBookmarkService.add(item)
        let fetchExp = expectation(description: "Fetch completed")
        sut.onUpdate = { fetchExp.fulfill() }
        sut.fetchItems()
        await fulfillment(of: [fetchExp], timeout: 2.0)
        var updateCalled = false
        sut.onUpdate = { updateCalled = true }
        sut.toggleBookmark(for: item)
        XCTAssertTrue(updateCalled)
        XCTAssertFalse(sut.isBookmarked(item))
        XCTAssertFalse(sut.items.first?.isBookmarked == true)
    }

    func testIsBookmarkedReturnsCorrectState() {
        let item = makeItem(link: "https://example.com/1")
        XCTAssertFalse(sut.isBookmarked(item))
        mockBookmarkService.add(item)
        XCTAssertTrue(sut.isBookmarked(item))
    }
}
