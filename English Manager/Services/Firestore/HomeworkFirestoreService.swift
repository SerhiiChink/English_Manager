//
//  HomeworkFirestoreService.swift
//  English Manager
//
//  Created by Sergej Klepikov on 23.03.2026.
//

import Foundation
import FirebaseFirestore

protocol HomeworkFirestoreServiceProtocol {
    func saveHomework(_ homework: Homework) async throws -> Homework
    func fetchHomework(teacherId: String) async throws -> [Homework]
    func fetchStudentHomework(studentId: String) async throws -> [Homework]
    func updateHomework(_ homework: Homework) async throws
    func deleteHomework(id: String) async throws
}

final class HomeworkFirestoreService: HomeworkFirestoreServiceProtocol {
    // MARK: - Properties
    private let db = Firestore.firestore()
    
    // MARK: - Private helpers
    private func collection(_ name: String) -> CollectionReference {
        db.collection(name)
    }
    
    // MARK: - Save Homework
    func saveHomework(_ homework: Homework) async throws -> Homework {
        let id = homework.id ?? collection(Collections.homeworks)
            .document().documentID
        var homework = homework
        homework.id = id
        try collection(Collections.homeworks)
            .document(id)
            .setData(from: homework)
        return homework
    }
    
    // MARK: - Fetch Homework
    func fetchHomework(teacherId: String) async throws -> [Homework] {
        let snapshot = try await collection(Collections.homeworks)
            .whereField("teacherId", isEqualTo: teacherId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return try snapshot.decode(Homework.self)
    }
    
    func fetchStudentHomework(studentId: String) async throws -> [Homework] {
        let snapshot = try await collection(Collections.homeworks)
            .whereField("studentId", isEqualTo: studentId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return try snapshot.decode(Homework.self)
    }
    
    // MARK: - Up date Homework
    func updateHomework(_ homework: Homework) async throws {
        guard let id = homework.id else { return }
        try collection(Collections.homeworks)
            .document(id)
            .setData(from: homework)
    }
    
    // MARK: - Delete Homework
    func deleteHomework(id: String) async throws {
        try await collection(Collections.homeworks)
            .document(id)
            .delete()
    }
}
