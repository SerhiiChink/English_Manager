//
//  OccurrenceFirestoreService.swift
//  English Manager
//
//  Created by Sergej Klepikov on 10.04.2026.
//

import Foundation
import FirebaseFirestore

protocol OccurrenceFirestoreServiceProtocol {
    func saveOccurrence(_ occurrence: LessonOccurrence) async throws -> LessonOccurrence
    func fetchOccurrences(studentId: String,
                          teacherId: String) async throws -> [LessonOccurrence]
    func cancelOccurrence(id: String, by cancelledBy: CancelledBy) async throws
    func linkLesson(occurrenceId: String, lessonId: String) async throws
    func fetchTodayOccurrences(studentId: String) async throws -> [LessonOccurrence]
    func fetchPendingConfirmations(teacherId: String) async throws -> [LessonOccurrence]
    func resolveOccurrence(id: String,
                           status: OccurrenceStatus) async throws
    func createOneTimeOccurrence(_ occurrence: LessonOccurrence) async throws
    func deleteOccurrence(id: String) async throws
}

final class OccurrenceFirestoreService: OccurrenceFirestoreServiceProtocol {
    // MARK: - Properties
    private let db = Firestore.firestore()
    
    // MARK: - Private helpers
    private func collection(_ name: String) -> CollectionReference {
        db.collection(name)
    }
    
    // MARK: - Occurrence
    func saveOccurrence(_ occurrence: LessonOccurrence) async throws -> LessonOccurrence {
        let id = occurrence.id ?? collection(Collections.lessonOccurrences)
            .document().documentID
        var occurrence = occurrence
        occurrence.id = id
        try collection(Collections.lessonOccurrences)
            .document(id)
            .setData(from: occurrence, merge: true)
        return occurrence
    }
    
    func fetchOccurrences(studentId: String,
                          teacherId: String) async throws -> [LessonOccurrence] {
        let snapshot = try await collection(Collections.lessonOccurrences)
            .whereField("studentId", isEqualTo: studentId)
            .whereField("teacherId", isEqualTo: teacherId)
            .order(by: "scheduledAt", descending: true)
            .getDocuments()
        return try snapshot.decode(LessonOccurrence.self)
    }
    
    func cancelOccurrence(id: String, by cancelledBy: CancelledBy) async throws {
        try await collection(Collections.lessonOccurrences)
            .document(id)
            .updateData([
                "status": OccurrenceStatus.cancelled.rawValue,
                "cancelledBy": cancelledBy.rawValue,
                "cancelledAt": FieldValue.serverTimestamp()
            ])
    }
    
    func linkLesson(occurrenceId: String, lessonId: String) async throws {
        try await collection(Collections.lessonOccurrences)
            .document(occurrenceId)
            .updateData(["lessonId": lessonId])
    }
    
    func fetchTodayOccurrences(studentId: String) async throws -> [LessonOccurrence] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day,
                                     value: 1,
                                     to: startOfDay)!
        let snapshot = try await collection(Collections.lessonOccurrences)
            .whereField("studentId", isEqualTo: studentId)
            .whereField("scheduledAt", isGreaterThan: startOfDay)
            .whereField("scheduledAt", isLessThan: endOfDay)
            .getDocuments()
        return try snapshot.decode(LessonOccurrence.self)
    }
    
    // MARK: - Confirmation
    func fetchPendingConfirmations(teacherId: String) async throws -> [LessonOccurrence] {
        let snapshot = try await collection(Collections.lessonOccurrences)
            .whereField("teacherId", isEqualTo: teacherId)
            .whereField("status", isEqualTo: OccurrenceStatus.completed.rawValue)
            .order(by: "scheduledAt")
            .getDocuments()
        return try snapshot.decode(LessonOccurrence.self)
    }
    
    func resolveOccurrence(id: String,
                           status: OccurrenceStatus) async throws {
        try await collection(Collections.lessonOccurrences)
            .document(id)
            .updateData(["status": status.rawValue])
    }
    
    func createOneTimeOccurrence(_ occurrence: LessonOccurrence) async throws {
        _ = try collection(Collections.lessonOccurrences)
            .addDocument(from: occurrence)
    }
    
    // MARK: - Delete Occurence
    func deleteOccurrence(id: String) async throws {
        try await collection(Collections.lessonOccurrences)
            .document(id)
            .delete()
    }
}
