//
//  MockFirestoreService.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 12.08.2026.
//

import Foundation
@testable import English_Manager

final class MockFirestoreService: FirestoreServiceProtocol {
    // MARK: - In-Memory Storage
    var users: [String: User] = [:]
    var lessons: [String: Lesson] = [:]
    var homeworks: [String: Homework] = [:]
    var schedules: [String: Schedule] = [:]
    
    // MARK: - Error Simulation
    var shouldReturnError = false
    var customError: Error = NSError(
        domain: "FirestoreError",
        code: -1,
        userInfo: [NSLocalizedDescriptionKey: "Mock Firestore Error"]
    )
    
    // MARK: - Call Trackers
    private(set) var saveUserCalled = false
    private(set) var updateFCMTokenCalledWith: (userId: String, token: String)?
    private(set) var adjustLessonsBalanceCalledWith: (userId: String,
                                                      delta: Int)?
    private(set) var removeStudentCalledWith: String?
    private func checkError() throws {
        if shouldReturnError {
            throw customError
        }
    }
    
    // MARK: - Users
    func saveUser(_ user: User) async throws {
        try checkError()
        saveUserCalled = true
        users[user.id] = user
    }
    
    func updateUserProfile(userId: String,
                           name: String,
                           surname: String) async throws {
        try checkError()
        users[userId]?.name = name
        users[userId]?.surname = surname
    }
    
    func fetchUser(id: String) async throws -> User {
        try checkError()
        guard let user = users[id] else {
            throw NSError(
                domain: "FirestoreError",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "User not found"]
            )
        }
        return user
    }
    
    func findUserByEmail(_ email: String) async throws -> User? {
        try checkError()
        return users.values.first { $0.email == email && $0.role == .student }
    }
    
    func updateUserRole(userId: String, role: UserRole) async throws {
        try checkError()
        users[userId]?.role = role
    }
    
    func updateUserAvatar(userId: String, url: String) async throws {
        try checkError()
        users[userId]?.photoURL = url
    }
    
    func updateUserTimezone(userId: String, timezone: String) async throws {
        try checkError()
        users[userId]?.timezone = timezone
    }
    
    func updateFCMToken(userId: String, token: String) async throws {
        try checkError()
        updateFCMTokenCalledWith = (userId, token)
        users[userId]?.fcmToken = token
    }
    
    // MARK: - Lessons
    func saveLesson(_ lesson: Lesson) async throws -> Lesson {
        try checkError()
        var updatedLesson = lesson
        let id = lesson.id ?? UUID().uuidString
        updatedLesson.id = id
        lessons[id] = updatedLesson
        return updatedLesson
    }
    
    func fetchLessons(teacherId: String) async throws -> [Lesson] {
        try checkError()
        return lessons.values.filter { $0.teacherId == teacherId }
    }
    
    func fetchStudentLessons(studentId: String) async throws -> [Lesson] {
        try checkError()
        return lessons.values.filter { $0.studentId == studentId }
    }
    
    func deleteLesson(id: String) async throws {
        try checkError()
        lessons.removeValue(forKey: id)
    }
    
    func adjustLessonsBalance(studentId: String, delta: Int) async throws {
        try checkError()
        adjustLessonsBalanceCalledWith = (studentId, delta)
        let currentBalance = users[studentId]?.lessonsBalance ?? 0
        users[studentId]?.lessonsBalance = currentBalance + delta
    }
    
    func setLessonsBalance(studentId: String, balance: Int) async throws {
        try checkError()
        users[studentId]?.lessonsBalance = balance
    }
    
    // MARK: - Students
    func fetchStudents(teacherId: String) async throws -> [User] {
        try checkError()
        return users.values.filter { $0.teacherId == teacherId && $0.role == .student }
    }
    
    func removeStudent(studentId: String) async throws {
        try checkError()
        removeStudentCalledWith = studentId
        users[studentId]?.teacherId = nil
        users[studentId]?.lessonsBalance = nil
    }
    
    // MARK: - Teacher
    func updateTeacher(studentId: String, teacherId: String) async throws {
        try checkError()
        users[studentId]?.teacherId = teacherId
    }
    
    // MARK: - Homework
    func saveHomework(_ homework: Homework) async throws {
        try checkError()
        var updatedHomework = homework
        let id = homework.id ?? UUID().uuidString
        updatedHomework.id = id
        homeworks[id] = updatedHomework
    }
    
    func fetchHomeworks(teacherId: String) async throws -> [Homework] {
        try checkError()
        return homeworks.values.filter { $0.teacherId == teacherId }
    }
    
    func fetchStudentHomeworks(studentId: String) async throws -> [Homework] {
        try checkError()
        return homeworks.values.filter { $0.studentId == studentId }
    }
    
    func updateHomework(_ homework: English_Manager.Homework) async throws {
        try checkError()
        guard let id = homework.id else { return }
        homeworks[id] = homework
    }
    
    // MARK: - Schedule
    func saveSchedule(_ schedule: Schedule) async throws -> Schedule {
        try checkError()
        var updatedSchedule = schedule
        let id = schedule.id ?? UUID().uuidString
        updatedSchedule.id = id
        schedules[id] = updatedSchedule
        return updatedSchedule
    }
    
    func fetchSchedules(teacherId: String) async throws -> [Schedule] {
        try checkError()
        return schedules.values.filter { $0.teacherId == teacherId && $0.isActive }
    }
    
    func fetchStudentSchedule(studentId: String) async throws -> [Schedule] {
        try checkError()
        return schedules.values.filter { $0.studentId == studentId && $0.isActive }
    }
    
    func deleteSchedule(id: String) async throws {
        try checkError()
        schedules.removeValue(forKey: id)
    }
}
