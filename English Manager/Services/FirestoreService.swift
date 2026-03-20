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
    func fetchUser(id: String) async throws -> User
    func saveLesson(_ lesson: Lesson) async throws
    func fetchLessons(teacherId: String) async throws -> [Lesson]
    func fetchStudentLessons(studentId: String) async throws -> [Lesson]
    func deleteLesson(id: String) async throws
    func fetchStudents(teacherId: String) async throws -> [User]
    func saveHomework(_ homework: Homework) async throws
    func fetchHomeworks(teacherId: String) async throws -> [Homework]
    func fetchStudentHomeworks(studentId: String) async throws -> [Homework]
    func updateHomework(_ homework: Homework) async throws
    func savePayment(_ payment: PaymentRequest) async throws
    func fetchPayments(teacherId: String) async throws -> [PaymentRequest]
    func fetchStudentPayments(studentId: String) async throws -> [PaymentRequest]
    func updatePayment(_ payment: PaymentRequest) async throws
    func findUserByEmail(_ email: String) async throws -> User?
    func updateTeacher(studentId: String,
                       teacherId: String) async throws
    func updateUserRole(userId: String, role: UserRole) async throws
    func updateUserName(userId: String, name: String) async throws
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
    
    func updateUserName(userId: String, name: String) async throws {
        try await collection(Collections.users)
            .document(userId)
            .updateData(["name": name])
    }
    
    func updateUserAvatar(userId: String, url: String) async throws {
        try await collection(Collections.users)
            .document(userId)
            .updateData(["photoURL": url])
    }
    
    // MARK: - Lessons
    func saveLesson(_ lesson: Lesson) async throws {
        let id = lesson.id ?? collection(Collections.lessons)
            .document().documentID
        var lesson = lesson
        lesson.id = id
        try collection(Collections.lessons)
            .document(id)
            .setData(from: lesson)
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
            .updateData(["teacherId": FieldValue.delete()])
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
            .order(by: "uploadedAt", descending: true)
            .getDocuments()
        return try snapshot.decode(Homework.self)
    }
    
    func fetchStudentHomeworks(studentId: String) async throws -> [Homework] {
        let snapshot = try await collection(Collections.homeworks)
            .whereField("studentId", isEqualTo: studentId)
            .order(by: "uploadedAt", descending: true)
            .getDocuments()
        return try snapshot.decode(Homework.self)
    }
    
    func updateHomework(_ homework: Homework) async throws {
        guard let id = homework.id else { return }
        try collection(Collections.homeworks)
            .document(id)
            .setData(from: homework)
    }
    
    // MARK: - Payments
    func savePayment(_ payment: PaymentRequest) async throws {
        let id = payment.id ?? collection(Collections.payments)
            .document().documentID
        var payment = payment
        payment.id = id
        try collection(Collections.payments)
            .document(id)
            .setData(from: payment)
    }
    
    func fetchPayments(teacherId: String) async throws -> [PaymentRequest] {
        let snapshot = try await collection(Collections.payments)
            .whereField("teacherId", isEqualTo: teacherId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return try snapshot.decode(PaymentRequest.self)
    }
    
    func fetchStudentPayments(studentId: String) async throws -> [PaymentRequest] {
        let snapshot = try await collection(Collections.payments)
            .whereField("studentId", isEqualTo: studentId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return try snapshot.decode(PaymentRequest.self)
    }
    
    func updatePayment(_ payment: PaymentRequest) async throws {
        guard let id = payment.id else { return }
        try collection(Collections.payments)
            .document(id)
            .setData(from: payment)
    }
}
