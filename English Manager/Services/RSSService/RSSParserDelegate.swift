//
//  RSSParserDelegate.swift
//  English Manager
//
//  Created by Sergej Klepikov on 13.08.2026.
//

import Foundation
 
final class RSSParserDelegate: NSObject, XMLParserDelegate {
    // MARK: - Properties
    private(set) var items: [RSSItem] = []
    private let dateFormatter: RSSDateFormatterProtocol
    private let source: String
    private var builder: RSSItemBuilder
    private var currentElement = ""
    private var currentValue = ""
    private var channelImageURL: String?
    private var isInsideItem = false
    private var isInsideChannelImage = false
 
    // MARK: - Init
    init(
        source: String,
        dateFormatter: RSSDateFormatterProtocol = RSSDateFormatter()
    ) {
        self.source = source
        self.dateFormatter = dateFormatter
        self.builder = RSSItemBuilder(dateFormatter: dateFormatter)
        super.init()
    }
 
    // MARK: - XMLParserDelegate
    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        currentElement = elementName
        currentValue = ""
        switch elementName {
        case "item", "entry":
            isInsideItem = true
            builder = RSSItemBuilder(dateFormatter: dateFormatter)
        case "image" where !isInsideItem:
            isInsideChannelImage = true
        case "media:thumbnail":
            if isInsideItem, let url = attributeDict["url"] {
                builder.imageURL = url
            }
        case "media:content":
            if isInsideItem,
               let url = attributeDict["url"],
               isImageAttributes(attributeDict) {
                builder.imageURL = url
            }
        case "enclosure":
            if isInsideItem { handleEnclosure(attributeDict) }
        case "itunes:image":
            if let href = attributeDict["href"] {
                let url = href.httpsNormalized
                isInsideItem ? (builder.itunesImage = url) : (channelImageURL = url)
            }
        case "link":
            if isInsideItem,
               let href = attributeDict["href"],
               !href.isEmpty,
               (attributeDict["rel"] ?? "alternate") == "alternate" {
                builder.link = href
            }
        default:
            break
        }
    }
 
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard isInsideItem || isInsideChannelImage else { return }
        currentValue += string
    }
 
    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        defer {
            if elementName == currentElement { currentElement = "" }
            currentValue = ""
        }
        switch elementName {
        case "url" where isInsideChannelImage:
            channelImageURL = currentValue.trimmed.httpsNormalized
            isInsideChannelImage = false
        case "title", "media:title":
            if isInsideItem, builder.title.isEmpty {
                builder.title = currentValue.trimmed
            }
        case "link", "feedburner:origLink":
            if isInsideItem, builder.link.isEmpty {
                builder.link = currentValue.trimmed
            }
        case "description", "summary", "content", "content:encoded", "media:description":
            if isInsideItem { appendDescription() }
        case "pubDate", "published", "updated":
            if isInsideItem, builder.pubDate.isEmpty {
                builder.pubDate = currentValue.trimmed
            }
        case "item", "entry":
            finalizeItem()
        default:
            break
        }
    }
 
    // MARK: - Private
    private func isImageAttributes(_ attributes: [String: String]) -> Bool {
        let medium = attributes["medium"] ?? ""
        let type   = attributes["type"] ?? ""
        let url    = attributes["url"] ?? ""
        return medium == "image"
            || type.hasPrefix("image")
            || url.hasSuffix(".jpg")
            || url.hasSuffix(".jpeg")
            || url.hasSuffix(".png")
            || url.hasSuffix(".webp")
    }
 
    private func handleEnclosure(_ attributes: [String: String]) {
        guard let url = attributes["url"] else { return }
        let type = attributes["type"] ?? ""
        if type.hasPrefix("image"), builder.imageURL == nil {
            builder.imageURL = url
        } else if (type.hasPrefix("audio") || url.contains(".mp3")), builder.audioURL == nil {
            builder.audioURL = url
        }
    }
 
    private func appendDescription() {
        let value = currentValue.trimmed
        guard !value.isEmpty else { return }
        if builder.imageURL == nil, let img = value.firstImageURL {
            builder.imageURL = img
        }
        if !builder.description.isEmpty { builder.description += "\n" }
        builder.description += value
    }
 
    private func finalizeItem() {
        if builder.imageURL == nil, builder.itunesImage.isEmpty {
            builder.itunesImage = channelImageURL ?? ""
        }
        if let item = builder.build(source: source) {
            items.append(item)
        }
        isInsideItem = false
        builder = RSSItemBuilder(dateFormatter: dateFormatter)
    }
}
