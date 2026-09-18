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
    var rescheduledLessons: [RescheduledLesson] { get }
    var teacherName: String? { get }
    var teacherTimezone: String? { get }
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
    private(set) var occurrences: [LessonOccurrence] = []
    private(set) var teacherName: String?
    private(set) var teacherTimezone: String?
    private var isFetching = false
    var rescheduledLessons: [RescheduledLesson] {
        occurrences
            .filter { $0.scheduleId == nil && $0.status == .scheduled }
            .compactMap { occurrence in
                guard let id = occurrence.id else { return nil }
                return RescheduledLesson(
                    id: id,
                    studentId: occurrence.studentId,
                    scheduledAt: occurrence.scheduledAt
                )
            }
    }

    // MARK: - Properties
    private let firestoreService: FirestoreServiceProtocol
    private let authService: AuthServiceProtocol
    private let occurrenceService: OccurrenceFirestoreServiceProtocol
    private let cache: UserCacheProtocol
    
    // MARK: - Init
    init(
        firestoreService: FirestoreServiceProtocol = FirestoreService(),
        authService: AuthServiceProtocol = AuthService(),
        occurrenceService: OccurrenceFirestoreServiceProtocol = OccurrenceFirestoreService(),
        cache: UserCacheProtocol = UserCache()
    ) {
        self.firestoreService = firestoreService
        self.authService = authService
        self.occurrenceService = occurrenceService
        self.cache = cache
    }
    
    // MARK: - Fetch
    func fetchLessons() {
        performFetch(forceRefresh: false)
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
                let user = try await cache.getUser(
                    id: studentId,
                    service: firestoreService,
                    forceRefresh: forceRefresh
                )
                guard let teacherId = user.teacherId else {
                    UserDefaults.standard.removeObject(
                        forKey: UDKeys.lastTeacherId(for: studentId)
                    )
                    await MainActor.run { [weak self] in
                        self?.isFetching = false
                        self?.onLoading?(false)
                        self?.onUpdate?()
                    }
                    return
                }
                let fetchedTeacher = try await cache
                    .getUser(id: teacherId, service: firestoreService, forceRefresh: forceRefresh)
                let isNewTeacher = checkNewTeacher(studentId: studentId,
                                                   teacherId: teacherId)
                async let lessons = firestoreService
                    .fetchStudentLessons(studentId: studentId)
                async let schedules = firestoreService
                    .fetchStudentSchedule(studentId: studentId)
                async let occurrences = occurrenceService
                    .fetchOccurrences(studentId: studentId,
                                      teacherId: teacherId)
                let (fetchedLessons,
                     fetchedSchedules,
                     fetchedOccurrences) = try await (lessons,
                                                      schedules,
                                                      occurrences)
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.lessons = fetchedLessons
                    self.schedules = fetchedSchedules
                    self.occurrences = fetchedOccurrences
                    self.teacherName = fetchedTeacher.shortName
                    self.teacherTimezone = fetchedTeacher.timezone
                    self.isFetching = false
                    self.onLoading?(false)
                    if isNewTeacher { self.onTeacherAssigned?() }
                    self.onUpdate?()
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
