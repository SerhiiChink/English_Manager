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
    var schedules: [Schedule] { get }
    var occurrences: [LessonOccurrence] { get }
    var filteredLessons: [Lesson] { get }
    var allSourceLink: [SourceLink] { get }
    func fetchLessons()
    func addLesson(_ lesson: Lesson, occurrence: LessonOccurrence?)
    func nextOccurrence(for schesule: Schedule) -> LessonOccurrence?
    func deleteLesson(lesson: Lesson,
                      completion: @escaping (Int?) -> Void)
    func saveSchedule(_ schedule: Schedule,
                      completion: @escaping (Schedule) -> Void)
    func deleteSchedule(_ schedule: Schedule)
    func schedules(for studentId: String) -> [Schedule]
    func filterByDate(_ date: Date?)
    func filterByStudent(_ studentId: String?)
    func checkDuplicateLink(_ url: String) -> Lesson?
    var currentTeacherId: String? { get }
    func updateLesson(_ lesson: Lesson)
    func updateAutoDebit(for student: User, isEnabled: Bool)
}

final class TeacherLessonsViewModel: TeacherLessonsViewModelProtocol {
    // MARK: - Callbacks
    var onUpdate: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoading: ((Bool) -> Void)?
    
    // MARK: - Data
    private var allLessons: [Lesson] = []
    private(set) var students: [User] = []
    private(set) var schedules: [Schedule] = []
    private(set) var occurrences: [LessonOccurrence] = []
    private var selectedDate: Date?
    private var selectedStudentId: String?
    private var isFetching = false
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
    private let occurrenceService: OccurrenceFirestoreServiceProtocol
    
    // MARK: - Init
    init(
        firestoreService: FirestoreServiceProtocol = FirestoreService(),
        authService: AuthServiceProtocol = AuthService(),
        occurrenceService: OccurrenceFirestoreServiceProtocol = OccurrenceFirestoreService()
    ) {
        self.firestoreService = firestoreService
        self.authService = authService
        self.occurrenceService = occurrenceService
    }
    
    // MARK: - Fetch
    func fetchLessons() {
        guard !isFetching else { return }
        guard let teacherId = authService.currentUserId else {
            onError?("The user is not authorized") // localiz
            return
        }
        isFetching = true
        onLoading?(true)
        Task {
            do {
                async let lessons = firestoreService.fetchLessons(teacherId: teacherId)
                async let students = firestoreService.fetchStudents(teacherId: teacherId)
                async let schedules = firestoreService.fetchSchedules(teacherId: teacherId)
                let (fetchedLessons,
                     fetchedStudents,
                     fetchedSchedules) = try await (lessons,
                                                    students,
                                                    schedules)
                let fetchedOccurrences = try await withThrowingTaskGroup(
                    of: [LessonOccurrence].self
                ) { group in
                    fetchedStudents.forEach { student in
                        group.addTask { [self] in
                            (try? await occurrenceService.fetchOccurrences(
                                studentId: student.id,
                                teacherId: teacherId
                            )) ?? []
                        }
                    }
                    var all: [LessonOccurrence] = []
                    for try await result in group { all += result }
                    return all
                }
                await MainActor.run { [weak self] in
                    self?.allLessons = fetchedLessons
                    self?.students = fetchedStudents
                    self?.schedules = fetchedSchedules
                    self?.occurrences = fetchedOccurrences
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
    
    // MARK: - Add Lessons
    func addLesson(_ lesson: Lesson, occurrence: LessonOccurrence?) {
        onLoading?(true)
        Task {
            do {
                let savedLesson = try await firestoreService.saveLesson(lesson)
                if let occurrenceId = occurrence?.id,
                   let lessonId = savedLesson.id {
                    try? await occurrenceService
                        .linkLesson(occurrenceId: occurrenceId,
                                    lessonId: lessonId)
                }

                await MainActor.run { [weak self] in
                    self?.allLessons.insert(savedLesson, at: 0)
                    self?.isFetching = false
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
    
    // MARK: - Up Date Lesson
    func updateLesson(_ lesson: Lesson) {
        onLoading?(true)
        Task {
            do {
                let savedLesson = try await firestoreService.saveLesson(lesson)
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    if let index = allLessons
                        .firstIndex(where: { $0.id == lesson.id }) {
                        allLessons[index] = savedLesson
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
    
    func updateAutoDebit(for student: User, isEnabled: Bool) {
        Task {
            do {
                try await firestoreService
                    .updateAutoDebit(studentId: student.id,
                                     isEnabled: isEnabled)
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    if let index = students.firstIndex(
                        where: { $0.id == student.id }
                    ) {
                        var updated = students[index]
                        updated.isAutoDebitEnabled = isEnabled
                        students[index] = updated
                    }
                    onUpdate?()
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Delete Lessons
    func deleteLesson(lesson: Lesson,
                      completion: @escaping (Int?) -> Void) {
        guard let id = lesson.id else { return }
        let index = filteredLessons.firstIndex { $0.id == id }
        onLoading?(true)
        Task {
            do {
                try await firestoreService.deleteLesson(id: id)
                await MainActor.run { [weak self] in
                    self?.allLessons.removeAll { $0.id == id }
                    self?.onLoading?(false)
                    completion(index)
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.onLoading?(false)
                    self?.onError?(error.localizedDescription)
                    completion(nil)
                }
            }
        }
    }
    
    // MARK: - Schedule Helpers
    func schedules(for studentId: String) -> [Schedule] {
        schedules.filter { $0.studentId == studentId }
    }
    
    func nextOccurrence(for schedule: Schedule) -> LessonOccurrence? {
        guard let scheduleId = schedule.id else { return nil }
        return occurrences
            .filter { $0.scheduleId == scheduleId && $0.status == .scheduled }
            .sorted { $0.scheduledAt < $1.scheduledAt }
            .first
    }
    
    // MARK: - Save Schedule
    func saveSchedule(_ schedule: Schedule,
                      completion: @escaping (Schedule) -> Void) {
        Task {
            do {
                let saved = try await firestoreService.saveSchedule(schedule)
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    if let index = schedules
                        .firstIndex(where: { $0.id == saved.id }) {
                        schedules[index] = saved
                    } else {
                        schedules.append(saved)
                    }
                    onUpdate?()
                    completion(saved)
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.onLoading?(false)
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Delete Schedule
    func deleteSchedule(_ schedule: Schedule) {
        guard let id = schedule.id else { return }
        Task {
            do {
                try await firestoreService.deleteSchedule(id: id)
                await MainActor.run { [weak self] in
                    self?.schedules.removeAll { $0.id == id }
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
    @MainActor
    func filterByDate(_ date: Date?) {
        selectedDate = date
        onUpdate?()
    }
    
    @MainActor
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
