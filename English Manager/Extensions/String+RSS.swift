//
//  String+RSS.swift
//  English Manager
//
//  Created by Sergej Klepikov on 13.08.2026.
//

import Foundation
 
extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
 
    var httpsNormalized: String {
        hasPrefix("http://")
            ? replacingOccurrences(of: "http://", with: "https://")
            : self
    }
 
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
 
    var cleanedHTML: String {
        self
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&nbsp;",  with: " ")
            .replacingOccurrences(of: "&amp;",   with: "&")
            .replacingOccurrences(of: "&quot;",  with: "\"")
            .replacingOccurrences(of: "&apos;",  with: "'")
            .replacingOccurrences(of: "&rsquo;", with: "'")
            .replacingOccurrences(of: "&#39;",   with: "'")
            .replacingOccurrences(of: "&#8217;", with: "'")
            .trimmed
    }
 
    var firstImageURL: String? {
        let pattern = #"src=["']([^"']+\.(?:jpg|jpeg|png|webp|gif)[^"']*)["']"#
        guard let regex = try? Regex(pattern).ignoresCase(),
              let match = firstMatch(of: regex),
              let range = match.output[1].range else { return nil }
        let url = String(self[range])
        let isIgnored = url.contains("gravatar.com") || url.contains("feedburner.com")
        return isIgnored ? nil : url
    }
}
