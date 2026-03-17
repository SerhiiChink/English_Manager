//
//  TeacherLessonsViewModel.swift
//  English Manager
//
//  Created by Sergej Klepikov on 14.03.2026.
//

import Foundation

protocol TeacherLessonsViewModelProtocol: AnyObject {
    var onUpdate: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var onLoading: ((Bool) -> Void)? { get set }
    var students: [User] { get }
    var filteredLessons: [Lesson] { get }
    var allSourceLink: [SourceLink] { get }
    func fetchLessons()
    func addLesson(_ lesson: Lesson)
    func deleteLesson(lesson: Lesson)
    func filterByDate(_ date: Date?)
    func filterByStudent(_ studentId: String?)
    func checkDuplicateLink(_ url: String) -> Lesson?
    var currentTeacherId: String? { get }
    func updateLesson(_ lesson: Lesson)
}

final class TeacherLessonsViewModel: TeacherLessonsViewModelProtocol {
    // MARK: - Callbacks
    var onUpdate: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoading: ((Bool) -> Void)?
    
    // MARK: - Data
    private var allLessons: [Lesson] = []
    private(set) var students: [User] = []
    private var selectedDate: Date?
    private var selectedStudentId: String?
    var filteredLessons: [Lesson] {
        var result = allLessons
        if let date = selectedDate {
            result = result.filter {
                Calendar.current.isDate($0.date, inSameDayAs: date)
            }
        }
        if let studentId = selectedStudentId {
            result = result.filter {
                $0.studentId == studentId
            }
        }
        return result
    }
    
    var allSourceLink: [SourceLink] {
        let link = allLessons.flatMap { $0.sourceLinks }
        return Array(Set(link))
    }
    
    var currentTeacherId: String? {
        authService.currentUserId
    }
    
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
        guard let teacherId = authService.currentUserId else {
            onError?("The user is not authorized") // localiz
            return
        }
        onLoading?(true)
        Task {
            do {
                async let lessons = firestoreService.fetchLessons(teacherId: teacherId)
                async let students = firestoreService.fetchStudents(teacherId: teacherId)
                let (fetchedLessons, fetchedStudents) = try await (lessons,
                                                                   students)
                await MainActor.run { [weak self] in
                    self?.allLessons = fetchedLessons
                    self?.students = fetchedStudents
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
    
    // MARK: - Add
    func addLesson(_ lessons: Lesson) {
        onLoading?(true)
        Task {
            do {
                try await firestoreService.saveLesson(lessons)
                await MainActor.run { [weak self] in
                    self?.onLoading?(false)
                    self?.fetchLessons()
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.onLoading?(false)
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Up Date Lesson
    func updateLesson(_ lesson: Lesson) {
        onLoading?(true)
        Task {
            do {
                try await firestoreService.saveLesson(lesson)
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    if let index = allLessons
                        .firstIndex(where: { $0.id == lesson.id }) {
                        allLessons[index] = lesson
                    }
                    onLoading?(false)
                    onUpdate?()
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
    func deleteLesson(lesson: Lesson) {
        guard let id = lesson.id else { return }
        onLoading?(true)
        Task {
            do {
                try await firestoreService.deleteLesson(id: id)
                await MainActor.run { [weak self] in
                    self?.allLessons.removeAll { $0.id == id }
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
    
    // MARK: - Filters
    func filterByDate(_ date: Date?) {
        selectedDate = date
        onUpdate?()
    }
    
    func filterByStudent(_ studentId: String?) {
        selectedStudentId = studentId
        onUpdate?()
    }
    
    func checkDuplicateLink(_ url: String) -> Lesson? {
        return allLessons.first {
            $0.sourceLinks.contains { $0.url == url }
        }
    }
}
