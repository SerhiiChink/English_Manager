//
//  MockRSSService.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 15.08.2026.
//

import Foundation
@testable import English_Manager

final class MockRSSService: RSSServiceProtocol {
    // MARK: - Properties
    var resultToReturn: Result<[RSSItem], Error> = .success([])
    private(set) var fetchedChannel: RSSChannel?
        
    // MARK: - Protocol Methods
    func fetchItems(from channel: RSSChannel) async throws -> [RSSItem] {
        fetchedChannel = channel
        switch resultToReturn {
        case let .success(items):
            return items
        case let .failure(error):
            throw error
        }
    }
}
