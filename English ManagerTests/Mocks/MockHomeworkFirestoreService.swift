//
//  MockHomeworkFirestoreService.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 12.08.2026.
//

import Foundation
@testable import English_Manager

final class MockHomeworkFirestoreService: HomeworkFirestoreServiceProtocol {
    // MARK: - In-Memory Storage
    var homeworks: [String: Homework] = [:]
    
    // MARK: - Error Simulation
    var shouldReturnError = false
    var customError: Error = NSError(
        domain: "HomeworkFirestoreError",
        code: -1,
        userInfo: [NSLocalizedDescriptionKey: "Mock Homework Firestore Error"]
    )
    
    // MARK: - Call Trackers
    private(set) var saveHomeworkCalled = false
    private(set) var updateHomeworkCalled = false
    private(set) var deleteHomeworkCalledWith: String?
    
    private func checkError() throws {
        if shouldReturnError {
            throw customError
        }
    }
    
    // MARK: - Methods
    func saveHomework(_ homework: Homework) async throws -> Homework {
        try checkError()
        saveHomeworkCalled = true
        var updatedHomework = homework
        let id = homework.id ?? UUID().uuidString
        updatedHomework.id = id
        homeworks[id] = updatedHomework
        return updatedHomework
    }
    
    func fetchHomework(teacherId: String) async throws -> [Homework] {
        try checkError()
        return homeworks.values.filter { $0.teacherId == teacherId }
    }
    
    func fetchStudentHomework(studentId: String) async throws -> [Homework] {
        try checkError()
        return homeworks.values.filter { $0.studentId == studentId }
    }
    
    func updateHomework(_ homework: Homework) async throws {
        try checkError()
        updateHomeworkCalled = true
        guard let id = homework.id else { return }
        homeworks[id] = homework
    }
    
    func deleteHomework(id: String) async throws {
        try checkError()
        deleteHomeworkCalledWith = id
        homeworks.removeValue(forKey: id)
    }
}
