//
//  RSSChannel.swift
//  English Manager
//
//  Created by Sergej Klepikov on 13.08.2026.
//

import Foundation
 
enum RSSChannel: String, CaseIterable {
    // MARK: - Cases
    case tedEd = "TED-Ed"
    case bbc6Min = "BBC 6 Minute English"
    case dailyTips = "Daily Writing Tips"
    case merriamW = "Merriam-Webster"
    case voa = "VOA Learning English"
    case culips = "Culips Everyday English"
    case espresso = "Espresso English"
    case grammarly = "Grammarly Blog"
 
    // MARK: - Feed URL
    var rssURL: String {
        switch self {
        case .tedEd:
            return "https://www.youtube.com/feeds/videos.xml?channel_id=UCsooa4yRKGN_zEE8iknghZA"
        case .bbc6Min:
            return "https://podcasts.files.bbci.co.uk/p02pc9tn.rss"
        case .dailyTips: 
            return "https://www.dailywritingtips.com/feed"
        case .merriamW: 
            return "https://www.merriam-webster.com/wotd/feed/rss2"
        case .voa:
            return "https://learningenglish.voanews.com/podcast/?count=20&zoneId=1689"
        case .culips:
            return "https://esl.culips.com/feed/podcast/"
        case .espresso:
            return "https://espressoenglish.libsyn.com/rss"
        case .grammarly: 
            return "https://www.grammarly.com/blog/feed"
        }
    }
 
    // MARK: - Display
    var shortName: String {
        switch self {
        case .tedEd: return "TED-Ed"
        case .bbc6Min: return "BBC"
        case .dailyTips: return "Daily Tips"
        case .merriamW: return "M-W Word"
        case .voa: return "VOA"
        case .culips: return "Culips"
        case .espresso: return "Espresso"
        case .grammarly: return "Grammarly"
        }
    }
 
    var iconName: String {
        switch self {
        case .tedEd: return "play.rectangle.fill"
        case .bbc6Min: return "headphones"
        case .dailyTips: return "text.alignleft"
        case .merriamW: return "character.book.closed.fill"
        case .voa: return "mic.fill"
        case .culips: return "waveform.and.mic"
        case .espresso: return "bolt.fill"
        case .grammarly: return "text.badge.checkmark"
        }
    }
}
