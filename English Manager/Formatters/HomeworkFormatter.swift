//
//  HomeworkFormatter.swift
//  English Manager
//
//  Created by Sergej Klepikov on 30.03.2026.
//

import Foundation

protocol HomeworkFormatterProtocol {
    func shortDateString(_ homework: Homework) -> String
    func longDateString(_ homework: Homework) -> String
    func cellModel(for homework: Homework,
                   showStudent: Bool) -> HomeworkCellModel
}

final class HomeworkFormatter: HomeworkFormatterProtocol {
    func shortDateString(_ homework: Homework) -> String {
        SharedDateFormatter.short.string(from: homework.createdAt)
    }
    
    func longDateString(_ homework: Homework) -> String {
        SharedDateFormatter.long.string(from: homework.createdAt)
    }
    
    func cellModel(for homework: Homework,
                   showStudent: Bool) -> HomeworkCellModel {
        let feedbackText: String? = homework.status != .pending
            ? (homework.teacherFeedback?.isEmpty == false ? homework.teacherFeedback : nil)
            : nil
        return HomeworkCellModel(
            dateText: shortDateString(homework),
            title: homework.title,
            description: homework.description.isEmpty
                ? nil
                : homework.description,
            studentName: showStudent
                ? homework.studentName
                : nil,
            feedbackText: feedbackText,
            statusStyle: HomeworkStatusMapper.style(for: homework)
        )
    }
}
