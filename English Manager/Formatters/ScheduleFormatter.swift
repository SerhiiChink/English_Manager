//
//  ScheduleFormatter.swift
//  English Manager
//
//  Created by Sergej Klepikov on 05.04.2026.
//

import Foundation

protocol ScheduleFormatterProtocol {
    func timeString(from date: Date) -> String
    func formatted(_ schedule: Schedule) -> String
    func formattedList(_ schedule: [Schedule]) -> String
    func shortFormatted(_ schedule: Schedule) -> String
    func shortFormattedList(_ schedule: [Schedule]) -> String
}

final class ScheduleFormatter: ScheduleFormatterProtocol {
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    private let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter
    }()
    
    // MARK: - Schedule
    func timeString(from date: Date) -> String {
        timeFormatter.string(from: date)
    }
    
    func formatted(_ schedule: Schedule) -> String {
        guard schedule.weekday >= 1 && schedule.weekday <= 7 else {
            return schedule.time
        }
        let adjustedIndex = schedule.weekday - 1
        let day = weekdayFormatter.weekdaySymbols[adjustedIndex]
        return "\(day) \(schedule.time)"
    }
    
    func formattedList(_ schedule: [Schedule]) -> String {
        schedule.map { formatted($0) }.joined(separator: " · ")
    }
    
    // MARK: - Short Form Schedule
    func shortFormatted(_ schedule: Schedule) -> String {
        guard schedule.weekday >= 1 && schedule.weekday <= 7 else {
            return schedule.time
        }
        let adjustedIndex = schedule.weekday % 7
        let day = weekdayFormatter.shortWeekdaySymbols[adjustedIndex]
        return "\(day) \(schedule.time)"
    }
    
    func shortFormattedList(_ schedule: [Schedule]) -> String {
        schedule.map { shortFormatted($0) }.joined(separator: ", ")
    }
}
