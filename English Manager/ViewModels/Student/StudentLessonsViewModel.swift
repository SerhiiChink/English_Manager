//
//  StudentLessonsViewModel.swift
//  English Manager
//
//  Created by Sergej Klepikov on 16.03.2026.
//

import Foundation

protocol StudentLessonsViewModelProtocol: AnyObject {
    var onUpdate: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var onLoading: ((Bool) -> Void)? { get set }
    var lessons: [Lesson] { get }
    func fetchLessons()
}

final class StudentLessonsViewModel: StudentLessonsViewModelProtocol {
    // MARK: - Callbacks
    var onUpdate: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoading: ((Bool) -> Void)?
    
    // MARK: - Data
    private(set) var lessons: [Lesson] = []
    
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
    func fetchLessons() {
        guard let studentId = authService.currentUserId else {
            onError?("User not found")
            return
        }
        onLoading?(true)
        Task {
            do {
                let lessons = try await firestoreService
                    .fetchStudentLessons(studentId: studentId)
                await MainActor.run { [weak self] in
                    self?.lessons = lessons
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
}
