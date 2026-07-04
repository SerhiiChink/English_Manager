//
//  TeacherHomeworkViewModel.swift
//  English Manager
//
//  Created by Sergej Klepikov on 23.03.2026.
//

import Foundation

protocol TeacherHomeworkViewModelProtocol: AnyObject {
    var onUpdate: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var onLoading: ((Bool) -> Void)? { get set }
    var filteredHomeworks: [Homework] { get }
    var students: [String] { get }
    func fetchHomework()
    func reviewHomework(_ homework: Homework,
                        grade: Int,
                        feedback: String)
    func filterByStudent(_ studentName: String?)
    func cellModel(for homework: Homework) -> HomeworkCellModel
}

final class TeacherHomeworkViewModel: TeacherHomeworkViewModelProtocol {
    // MARK: - Callbacks
    var onUpdate: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoading: ((Bool) -> Void)?
    
    // MARK: - Data
    private var allHomework: [Homework] = []
    private var selectedStudentName: String?
    private var isFetching = false
    var filteredHomeworks: [Homework] {
        guard let name = selectedStudentName else { return allHomework }
        return allHomework.filter { $0.studentName == name }
    }
    var students: [String] {
        Array(Set(allHomework.map { $0.studentName }))
            .filter { !$0.isEmpty }
            .sorted()
    }
    
    // MARK: - Properties
    private let homeworkService: HomeworkFirestoreServiceProtocol
    private let authService: AuthServiceProtocol
    private let formatter: HomeworkFormatterProtocol = HomeworkFormatter()
    
    // MARK: - Init
    init(
        homeworkService: HomeworkFirestoreServiceProtocol = HomeworkFirestoreService(),
        authService: AuthServiceProtocol = AuthService()
    ) {
        self.homeworkService = homeworkService
        self.authService = authService
    }
    
    // MARK: - Fetch
    func fetchHomework() {
        guard !isFetching else { return }
        guard let teacherId = authService.currentUserId else {
            onError?("User not found")
            return
        }
        isFetching = true
        onLoading?(true)
        Task {
            do {
                let homeworks = try await homeworkService
                    .fetchHomework(teacherId: teacherId)
                await MainActor.run { [weak self] in
                    self?.allHomework = homeworks
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
    
    // MARK: - Review
    func reviewHomework(_ homework: Homework,
                        grade: Int,
                        feedback: String) {
        var updated = homework
        updated.status = .reviewed
        updated.grade = grade
        updated.teacherFeedback = feedback
        updated.reviewedAt = Date()
        onLoading?(true)
        Task {
            do {
                try await homeworkService.updateHomework(updated)
                await MainActor.run { [weak self] in
                    if let index = self?.allHomework
                        .firstIndex(where: { $0.id == updated.id }) {
                        self?.allHomework[index] = updated
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
    
    // MARK: - Filter
    func filterByStudent(_ studentName: String?) {
        selectedStudentName = studentName
        onUpdate?()
    }
    
    // MARK: - Cell Model
    func cellModel(for homework: Homework) -> HomeworkCellModel {
        formatter.cellModel(for: homework, showStudent: true)
    }
}
