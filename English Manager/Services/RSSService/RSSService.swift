//
//  RSSService.swift
//  English Manager
//
//  Created by Sergej Klepikov on 13.08.2026.
//

import Foundation

protocol RSSServiceProtocol {
    func fetchItems(from channel: RSSChannel) async throws -> [RSSItem]
}

final class RSSService: RSSServiceProtocol {
    // MARK: - Fetch
    func fetchItems(from channel: RSSChannel) async throws -> [RSSItem] {
        guard let url = URL(string: channel.rssURL) else {
            throw RSSError.invalidURL
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try parse(data: data, source: channel.shortName)
    }
    
    // MARK: - Private
    private func parse(data: Data, source: String) throws -> [RSSItem] {
        let delegate = RSSParserDelegate(source: source)
        let parser = XMLParser(data: data)
        parser.delegate = delegate
        guard parser.parse() else {
            throw RSSError.parsingFailed
        }
        return delegate.items
    }
}
