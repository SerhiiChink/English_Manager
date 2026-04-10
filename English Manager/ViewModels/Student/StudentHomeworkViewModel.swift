//
//  StudentHomeworkViewModel.swift
//  English Manager
//
//  Created by Sergej Klepikov on 23.03.2026.
//

import Foundation

protocol StudentHomeworkViewModelProtocol: AnyObject {
    var onUpdate: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var onLoading: ((Bool) -> Void)? { get set }
    var homeworks: [Homework] { get }
    func fetchHomeworks()
    func addHomework(title: String,
                     description: String,
                     link: String)
    func deleteHomework(_ homework: Homework)
    func updateHomework(_ homework: Homework,
                        title: String,
                        description: String,
                        link: String)
    func markAsSeen(_ homework: Homework)
}

final class StudentHomeworkViewModel: StudentHomeworkViewModelProtocol {
    // MARK: - Callbacks
    var onUpdate: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoading: ((Bool) -> Void)?
    
    // MARK: - Data
    private(set) var homeworks: [Homework] = []
    private var currentUser: User?
    private var isFetching = false
    
    // MARK: - Properties
    private let homeworkService: HomeworkFirestoreServiceProtocol
    private let firestoreService: FirestoreServiceProtocol
    private let authService: AuthServiceProtocol
    
    // MARK: - Init
    init(
        homeworkService: HomeworkFirestoreServiceProtocol = HomeworkFirestoreService(),
        firestoreService: FirestoreServiceProtocol = FirestoreService(),
        authService: AuthServiceProtocol = AuthService()
    ) {
        self.homeworkService = homeworkService
        self.firestoreService = firestoreService
        self.authService = authService
    }
    
    // MARK: - Fetch
    func fetchHomeworks() {
        guard !isFetching else { return }
        guard let studentId = authService.currentUserId else {
            onError?("User not found")
            return
        }
        isFetching = true
        onLoading?(true)
        Task {
            do {
                async let homeworks = homeworkService
                    .fetchStudentHomework(studentId: studentId)
                async let user = firestoreService.fetchUser(id: studentId)
                let (fetchedHomeworks, fetchedUser) = try await (homeworks, user)
                await MainActor.run { [weak self] in
                    self?.homeworks = fetchedHomeworks
                    self?.currentUser = fetchedUser
                    self?.isFetching = false
                    self?.onLoading?(false)
                    self?.onUpdate?()
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.isFetching = false
                    self?.onLoading?(false)
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Add
    func addHomework(title: String,
                     description: String,
                     link: String) {
        guard let studentId = authService.currentUserId else { return }
        guard let teacherId = currentUser?.teacherId else {
            onError?("No teacher assigned. Contact your teacher to link accounts.")
            return
        }
        let homework = Homework(studentId: studentId,
                                teacherId: teacherId,
                                lessonId: nil,
                                studentName: currentUser?.displayName ?? "",
                                title: title,
                                description: description,
                                sourceLink: link,
                                status: .pending,
                                grade: nil,
                                teacherFeedback: nil,
                                createdAt: Date(),
                                reviewedAt: nil)
        onLoading?(true)
        Task {
            do {
                let saved = try await homeworkService.saveHomework(homework)
                await MainActor.run { [weak self] in
                    self?.homeworks.insert(saved, at: 0)
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
    
    // MARK: - Delete
    func deleteHomework(_ homework: Homework) {
        guard let id = homework.id else { return }
        onLoading?(true)
        Task {
            do {
                try await homeworkService.deleteHomework(id: id)
                await MainActor.run { [weak self] in
                    self?.homeworks.removeAll { $0.id == id }
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
    
    // MARK: - Update
    func updateHomework(_ homework: Homework,
                        title: String,
                        description: String,
                        link: String) {
        var updated = homework
        updated.title = title
        updated.description = description
        updated.sourceLink = link
        onLoading?(true)
        Task {
            do {
                try await firestoreService.updateHomework(updated)
                await MainActor.run { [weak self] in
                    if let index = self?.homeworks
                        .firstIndex(where: { $0.id == updated.id }) {
                        self?.homeworks[index] = updated
                    }
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
    
    func markAsSeen(_ homework: Homework) {
        guard homework.status == .reviewed else { return }
        var updated = homework
        updated.status = .seen
        Task {
            do {
                try? await firestoreService.updateHomework(updated)
                await MainActor.run { [weak self] in
                    if let index = self?.homeworks
                        .firstIndex(where: { $0.id == updated.id }) {
                        self?.homeworks[index] = updated
                    }
                    self?.onUpdate?()
                }
            }
        }
    }
}


