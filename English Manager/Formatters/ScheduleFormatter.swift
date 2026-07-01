//
//  ScheduleFormatter.swift
//  English Manager
//
//  Created by Sergej Klepikov on 05.04.2026.
//

import Foundation

protocol ScheduleFormatterProtocol {
    func timeString(from date: Date) -> String
    func formatted(_ schedule: Schedule, timezone: String?) -> String
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
    
    func formatted(_ schedule: Schedule, timezone: String? = nil) -> String {
        guard schedule.weekday >= 1 && schedule.weekday <= 7 else {
            return "\(schedule.time)\(tzSuffix(from: timezone))"
        }
        let adjustedIndex = schedule.weekday - 1
        let day = weekdayFormatter.weekdaySymbols[adjustedIndex]
        return "\(day) \(schedule.time)\(tzSuffix(from: timezone))"
    }

    // MARK: - Private
    private func tzSuffix(from identifier: String?) -> String {
        guard let identifier else { return "" }
        let city = identifier.components(separatedBy: "/").last ?? ""
        return city.isEmpty ? "" : " (\(city))"
    }
}
