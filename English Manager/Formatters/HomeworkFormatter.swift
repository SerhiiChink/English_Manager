//
//  HomeworkFormatter.swift
//  English Manager
//
//  Created by Sergej Klepikov on 30.03.2026.
//

import Foundation

protocol HomeworkFormatterProtocol {
    func createdDateString(_ homework: Homework) -> String
}

final class HomeworkFormatter: HomeworkFormatterProtocol {
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()
    
    func createdDateString(_ homework: Homework) -> String {
        Self.formatter.string(from: homework.createdAt)
    }
}
