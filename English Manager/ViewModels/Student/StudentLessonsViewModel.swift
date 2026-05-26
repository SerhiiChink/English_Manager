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
    var onTeacherAssigned: (() -> Void)? { get set }
    var lessons: [Lesson] { get }
    var schedules: [Schedule] { get }
    var teacherName: String? { get }
    var isAutoDebitEnabled: Bool { get }
    func fetchLessons()
    func refresh()
}

final class StudentLessonsViewModel: StudentLessonsViewModelProtocol {
    // MARK: - Callbacks
    var onUpdate: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoading: ((Bool) -> Void)?
    var onTeacherAssigned: (() -> Void)?
    
    // MARK: - Data
    private(set) var lessons: [Lesson] = []
    private(set) var schedules: [Schedule] = []
    private(set) var teacherName: String?
    private(set) var isAutoDebitEnabled: Bool = false
    private var isFetching = false
    
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
        performFetch(forceRefresh: true)
    }
    
    func refresh() {
        performFetch(forceRefresh: true)
    }

    private func performFetch(forceRefresh: Bool) {
        guard !isFetching else { return }
        guard let studentId = authService.currentUserId else {
            onError?("User not found")
            return
        }
        isFetching = true
        onLoading?(true)
        Task {
            do {
                let user = try await UserCache.shared.getUser(
                    id: studentId,
                    service: firestoreService,
                    forceRefresh: forceRefresh
                )
                guard let teacherId = user.teacherId else {
                    UserDefaults.standard.removeObject(
                        forKey: "lastTeacherId_\(studentId)"
                    )
                    await MainActor.run { [weak self] in
                        self?.isFetching = false
                        self?.onLoading?(false)
                        self?.onUpdate?()
                    }
                    return
                }
                let fetchedTeacher = try await UserCache.shared
                    .getUser(id: teacherId, service: firestoreService)
                let isNewTeacher = checkNewTeacher(studentId: studentId,
                                                   teacherId: teacherId)
                async let lessons = firestoreService
                    .fetchStudentLessons(studentId: studentId)
                async let schedules = firestoreService
                    .fetchStudentSchedule(studentId: studentId)
                let (fetchedLessons,
                     fetchedSchedules) = try await (lessons,
                                                      schedules)
                await MainActor.run { [weak self] in
                    self?.lessons = fetchedLessons
                    self?.schedules = fetchedSchedules
                    self?.teacherName = fetchedTeacher.shortName
                    self?.isAutoDebitEnabled = user.isAutoDebitEnabled ?? false
                    self?.isFetching = false
                    self?.onLoading?(false)
                    if isNewTeacher { self?.onTeacherAssigned?() }
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
    
    private func checkNewTeacher(studentId: String,
                                 teacherId: String) -> Bool {
        guard UserDefaults.standard.string(
            forKey: UDKeys.lastTeacherId(for: studentId)
        ) != teacherId else { return false }
        UserDefaults.standard.set(
            teacherId,
            forKey: UDKeys.lastTeacherId(for: studentId)
        )
        return true
    }
}
