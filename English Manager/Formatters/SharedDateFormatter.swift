//
//  SharedDateFormatter.swift
//  English Manager
//
//  Created by Sergej Klepikov on 22.05.2026.
//

import Foundation

enum SharedDateFormatter {
    static let short: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd.MM.yy"
        return f
    }()
    
    static let long: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd MMM yyyy"
        return f
    }()
}
