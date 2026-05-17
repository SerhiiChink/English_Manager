//
//  StudentsViewModel.swift
//  English Manager
//
//  Created by Sergej Klepikov on 15.03.2026.
//

import Foundation

protocol StudentsViewModelProtocol: AnyObject {
    var onUpdate: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var onLoading: ((Bool) -> Void)? { get set }
    var students: [User] { get }
    func fetchStudents()
    func addStudent(email: String, name: String)
    func removeStudent(_ student: User)
}

final class StudentsViewModel: StudentsViewModelProtocol {
    // MARK: - Callbacks
    var onUpdate: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoading: ((Bool) -> Void)?
    
    // MARK: - Data
    private(set) var students: [User] = []
    
    // MARK: - Properties
    private let firestoreService: FirestoreServiceProtocol
    private let authService: AuthServiceProtocol
    
    // MARK: - Init
    init(
        firestoreService: FirestoreServiceProtocol = FirestoreService(),
        authService: AuthServiceProtocol = AuthService()
    ) {
        self.firestoreService = firestoreService
        self.authService = authService
    }
    
    // MARK: - Fetch
    func fetchStudents() {
        guard let teacherId = authService.currentUserId else {
            onError?("User not found")
            return
        }
        onLoading?(true)
        Task {
            do {
                let students = try await firestoreService
                    .fetchStudents(teacherId: teacherId)
                await MainActor.run { [weak self] in
                    self?.students = students
                    self?.onLoading?(false)
                    self?.onUpdate?()
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.onLoading?(false)
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Add Student
    func addStudent(email: String, name: String) {
        guard let teacherId = authService.currentUserId else { return }
        onLoading?(true)
        Task {
            do {
                guard let student = try await firestoreService
                    .findUserByEmail(email) else {
                    await MainActor.run { [weak self] in
                        self?.onLoading?(false)
                        self?.onError?("User not found")
                    }
                    return
                }
                if student.teacherId != nil {
                    await MainActor.run { [weak self] in
                        self?.onLoading?(false)
                        self?.onError?("Student already has a teacher")
                    }
                    return
                }
                if !name.isEmpty {
                    try await firestoreService.updateTeacherAlias(
                        studentId: student.id,
                        alias: name
                    )
                }
                try await firestoreService.updateTeacher(
                    studentId: student.id,
                    teacherId: teacherId
                )
                await MainActor.run { [weak self] in
                    self?.onLoading?(false)
                    self?.fetchStudents()
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.onLoading?(false)
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Remove Student
    func removeStudent(_ student: User) {
        Task {
            do {
                try await firestoreService.removeStudent(studentId: student.id)
                UserCache.shared.invalidate(userId: student.id)
                await MainActor.run { [weak self] in
                    self?.students.removeAll { $0.id == student.id }
                    self?.onUpdate?()
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
}
