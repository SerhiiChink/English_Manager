//
//  RSSItemBuilder.swift
//  English Manager
//
//  Created by Sergej Klepikov on 13.08.2026.
//

import Foundation
 
final class RSSItemBuilder {
    // MARK: - Properties
    var title = ""
    var link = ""
    var description = ""
    var imageURL: String?
    var itunesImage = ""
    var audioURL: String?
    var pubDate = ""
 
    private let dateFormatter: RSSDateFormatterProtocol
 
    // MARK: - Init
    init(dateFormatter: RSSDateFormatterProtocol = RSSDateFormatter()) {
        self.dateFormatter = dateFormatter
    }
 
    // MARK: - Build
    func build(source: String) -> RSSItem? {
        let trimmedTitle = title.trimmed
        let trimmedLink  = link.trimmed
        guard !trimmedTitle.isEmpty,
              !trimmedLink.isEmpty || audioURL != nil else { return nil }
        return RSSItem(
            title: trimmedTitle,
            link: trimmedLink.isEmpty ? (audioURL ?? "") : trimmedLink,
            description: description.cleanedHTML.nilIfEmpty,
            imageURL: resolvedImage,
            audioURL: audioURL,
            pubDate: dateFormatter.date(from: pubDate.trimmed),
            source: source
        )
    }
 
    // MARK: - Private
    private var resolvedImage: String? {
        if let url = imageURL, !url.isEmpty { return url.httpsNormalized }
        if !itunesImage.isEmpty { return itunesImage.httpsNormalized }
        return description.firstImageURL?.httpsNormalized
    }
}
