//
//  MockOccurrenceFirestoreService.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 12.08.2026.
//

import Foundation
@testable import English_Manager

final class MockOccurrenceFirestoreService: OccurrenceFirestoreServiceProtocol {
    // MARK: - In-Memory Storage
    var occurrences: [String: LessonOccurrence] = [:]
    
    // MARK: - Error Simulation
    var shouldReturnError = false
    var customError: Error = NSError(
        domain: "OccurrenceFirestoreError",
        code: -1,
        userInfo: [NSLocalizedDescriptionKey: "Mock Occurrence Firestore Error"]
    )
    
    // MARK: - Call Trackers
    private(set) var saveOccurrenceCalled = false
    private(set) var cancelOccurrenceCalledWith: (id: String,
                                                  cancelledBy: CancelledBy)?
    private(set) var linkLessonCalledWith: (occurrenceId: String,
                                            lessonId: String)?
    private(set) var resolveOccurrenceCalledWith: (id: String,
                                                   status: OccurrenceStatus)?
    private(set) var createOneTimeOccurrenceCalled = false
    private(set) var deleteOccurrenceCalledWith: String?
    private func checkError() throws {
        if shouldReturnError {
            throw customError
        }
    }
    
    // MARK: - Methods
    func saveOccurrence(_ occurrence: LessonOccurrence) async throws -> LessonOccurrence {
        try checkError()
        saveOccurrenceCalled = true
        var updatedOccurrence = occurrence
        let id = updatedOccurrence.id ?? UUID().uuidString
        updatedOccurrence.id = id
        occurrences[id] = updatedOccurrence
        return updatedOccurrence
    }
    
    func fetchOccurrences(studentId: String,
                          teacherId: String) async throws -> [LessonOccurrence] {
        try checkError()
        return occurrences.values.filter { $0.studentId == studentId && $0.teacherId == teacherId }
    }
    
    func cancelOccurrence(id: String,
                          by cancelledBy: CancelledBy) async throws {
        try checkError()
        cancelOccurrenceCalledWith = (id, cancelledBy)
        occurrences[id]?.status = .cancelled
        occurrences[id]?.cancelledBy = cancelledBy
        occurrences[id]?.cancelledAt = Date()
    }
    
    func linkLesson(occurrenceId: String, lessonId: String) async throws {
        try checkError()
        linkLessonCalledWith = (occurrenceId, lessonId)
        occurrences[occurrenceId]?.lessonId = lessonId
    }
    
    func fetchTodayOccurrences(studentId: String) async throws -> [LessonOccurrence] {
        try checkError()
        let calendar = Calendar.current
        return occurrences.values.filter {
            guard $0.studentId == studentId else { return false }
            return calendar.isDateInToday($0.scheduledAt)
        }
    }
    
    func fetchPendingConfirmations(teacherId: String) async throws -> [LessonOccurrence] {
        try checkError()
        return occurrences.values.filter {
            $0.teacherId == teacherId && $0.status == .completed
        }
    }
    
    func resolveOccurrence(id: String, status: OccurrenceStatus) async throws {
        try checkError()
        resolveOccurrenceCalledWith = (id, status)
        occurrences[id]?.status = status
    }
    
    func createOneTimeOccurrence(_ occurrence: LessonOccurrence) async throws {
        try checkError()
        createOneTimeOccurrenceCalled = true
        let id = occurrence.id ?? UUID().uuidString
        var newOccurrence = occurrence
        newOccurrence.id = id
        occurrences[id] = newOccurrence
    }
    
    func deleteOccurrence(id: String) async throws {
        try checkError()
        deleteOccurrenceCalledWith = id
        occurrences.removeValue(forKey: id)
    }
}
