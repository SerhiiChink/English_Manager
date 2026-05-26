//
//  FirestoreService.swift
//  English Manager
//
//  Created by Sergej Klepikov on 14.03.2026.
//

import Foundation
import FirebaseFirestore

protocol FirestoreServiceProtocol {
    func saveUser(_ user: User) async throws
    func updateUserProfile(userId: String,
                           name: String,
                           surname: String) async throws
    func fetchUser(id: String) async throws -> User
    func saveLesson(_ lesson: Lesson) async throws -> Lesson
    func fetchLessons(teacherId: String) async throws -> [Lesson]
    func fetchStudentLessons(studentId: String) async throws -> [Lesson]
    func deleteLesson(id: String) async throws
    func adjustLessonsBalance(studentId: String, delta: Int) async throws
    func setLessonsBalance(studentId: String, balance: Int) async throws
    func fetchStudents(teacherId: String) async throws -> [User]
    func saveHomework(_ homework: Homework) async throws
    func fetchHomeworks(teacherId: String) async throws -> [Homework]
    func fetchStudentHomeworks(studentId: String) async throws -> [Homework]
    func updateHomework(_ homework: Homework) async throws
    func saveSchedule(_ schedule: Schedule) async throws -> Schedule
    func fetchSchedules(teacherId: String) async throws -> [Schedule]
    func fetchStudentSchedule(studentId: String) async throws -> [Schedule]
    func updateAutoDebit(studentId: String, isEnabled: Bool) async throws
    func deleteSchedule(id: String) async throws
    func findUserByEmail(_ email: String) async throws -> User?
    func updateTeacher(studentId: String,
                       teacherId: String) async throws
    func updateUserRole(userId: String, role: UserRole) async throws
    func updateUserAvatar(userId: String, url: String) async throws
    func removeStudent(studentId: String) async throws
}

final class FirestoreService: FirestoreServiceProtocol {
    // MARK: - Properties
    private let db = Firestore.firestore()
    
    // MARK: - Private helpers
    private func collection(_ name: String) -> CollectionReference {
        db.collection(name)
    }
    
    // MARK: - Users
    func saveUser(_ user: User) async throws {
        try collection(Collections.users)
            .document(user.id)
            .setData(from: user)
    }
    
    func fetchUser(id: String) async throws -> User {
        try await collection(Collections.users)
            .document(id)
            .getDocument(as: User.self)
    }
    
    func findUserByEmail(_ email: String) async throws -> User? {
        let snapshot = try await collection(Collections.users)
            .whereField("email", isEqualTo: email)
            .whereField("role", isEqualTo: UserRole.student.rawValue)
            .getDocuments()
        return try snapshot.documents.first.flatMap {
            try $0.data(as: User.self)
        }
    }
    
    func updateUserRole(userId: String, role: UserRole) async throws {
        try await collection(Collections.users)
            .document(userId)
            .updateData(["role": role.rawValue])
    }
    
    func updateUserAvatar(userId: String, url: String) async throws {
        try await collection(Collections.users)
            .document(userId)
            .updateData(["photoURL": url])
    }
    
    func updateUserProfile(userId: String,
                           name: String,
                           surname: String) async throws {
        try await collection(Collections.users)
            .document(userId)
            .updateData([
                "name": name,
                "surname": surname,
            ])
    }
    
    // MARK: - Lessons
    func saveLesson(_ lesson: Lesson) async throws -> Lesson {
        let id = lesson.id ?? collection(Collections.lessons)
            .document().documentID
        var lesson = lesson
        lesson.id = id
        try collection(Collections.lessons)
            .document(id)
            .setData(from: lesson)
        return lesson
    }
    
    func fetchLessons(teacherId: String) async throws -> [Lesson] {
        let snapshot = try await collection(Collections.lessons)
            .whereField("teacherId", isEqualTo: teacherId)
            .order(by: "date", descending: true)
            .getDocuments()
        return try snapshot.decode(Lesson.self)
    }
    
    func fetchStudentLessons(studentId: String) async throws -> [Lesson] {
        let snapshot = try await collection(Collections.lessons)
            .whereField("studentId", isEqualTo: studentId)
            .order(by: "date", descending: true)
            .getDocuments()
        return try snapshot.decode(Lesson.self)
    }
    
    func deleteLesson(id: String) async throws {
        try await collection(Collections.lessons)
            .document(id)
            .delete()
    }
    
    func adjustLessonsBalance(studentId: String, delta: Int) async throws {
        try await collection(Collections.users)
            .document(studentId)
            .updateData([
                "lessonsBalance": FieldValue.increment(Int64(delta)),
            ])
    }
    
    func setLessonsBalance(studentId: String, balance: Int) async throws {
        try await collection(Collections.users)
            .document(studentId)
            .updateData(["lessonsBalance": balance])
    }
    
    // MARK: - Students
    func fetchStudents(teacherId: String) async throws -> [User] {
        let snapshot = try await collection(Collections.users)
            .whereField("teacherId", isEqualTo: teacherId)
            .whereField("role", isEqualTo: UserRole.student.rawValue)
            .getDocuments()
        return try snapshot.decode(User.self)
    }
    
    func removeStudent(studentId: String) async throws {
        try await collection(Collections.users)
            .document(studentId)
            .updateData([
                "teacherId": FieldValue.delete(),
                "teacherAlias": FieldValue.delete(),
                "isAutoDebitEnabled": FieldValue.delete(),
                "lessonsBalance": FieldValue.delete(),
                "totalLessonsPaid": FieldValue.delete()
            ])
    }
    
    // MARK: - Teacher
    func updateTeacher(studentId: String,
                       teacherId: String) async throws {
        try await collection(Collections.users)
            .document(studentId)
            .updateData(["teacherId": teacherId])
    }
    
    // MARK: - Homework
    func saveHomework(_ homework: Homework) async throws {
        let id = homework.id ?? collection(Collections.homeworks)
            .document().documentID
        var homework = homework
        homework.id = id
        try collection(Collections.homeworks)
            .document(id)
            .setData(from: homework)
    }
    
    func fetchHomeworks(teacherId: String) async throws -> [Homework] {
        let snapshot = try await collection(Collections.homeworks)
            .whereField("teacherId", isEqualTo: teacherId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return try snapshot.decode(Homework.self)
    }
    
    func fetchStudentHomeworks(studentId: String) async throws -> [Homework] {
        let snapshot = try await collection(Collections.homeworks)
            .whereField("studentId", isEqualTo: studentId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return try snapshot.decode(Homework.self)
    }
    
    func updateHomework(_ homework: Homework) async throws {
        guard let id = homework.id else { return }
        try collection(Collections.homeworks)
            .document(id)
            .setData(from: homework)
    }
    
    // MARK: - Schedule
    func saveSchedule(_ schedule: Schedule) async throws -> Schedule {
        let id = schedule.id ?? collection(Collections.schedules)
            .document().documentID
        var schedule = schedule
        schedule.id = id
        try collection(Collections.schedules)
            .document(id)
            .setData(from: schedule)
        return schedule
    }
    
    func fetchSchedules(teacherId: String) async throws -> [Schedule] {
        let snapshot = try await collection(Collections.schedules)
            .whereField("teacherId", isEqualTo: teacherId)
            .whereField("isActive", isEqualTo: true)
            .getDocuments()
        return try snapshot.decode(Schedule.self)
    }
    
    func fetchStudentSchedule(studentId: String) async throws -> [Schedule] {
        let snapshot = try await collection(Collections.schedules)
            .whereField("studentId", isEqualTo: studentId)
            .whereField("isActive", isEqualTo: true)
            .getDocuments()
        return try snapshot.decode(Schedule.self)
    }
    
    func updateAutoDebit(studentId: String, isEnabled: Bool) async throws {
        try await collection(Collections.users)
            .document(studentId)
            .updateData(["isAutoDebitEnabled": isEnabled])
    }
    
    func deleteSchedule(id: String) async throws {
        try await collection(Collections.schedules)
            .document(id)
            .delete()
    }
}
