//
//  LessonOccurrenceViewModel.swift
//  English Manager
//
//  Created by Sergej Klepikov on 10.04.2026.
//

import Foundation

protocol LessonOccurrenceViewModelProtocol: AnyObject {
    var onUpdate: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var todayOccurrences: [LessonOccurrence] { get }
    func fetchTodayOccurrences()
    func cancelOccurrences(_ occurrence: LessonOccurrence,
                           by cancelledBy: CancelledBy)
}

final class LessonOccurrenceViewModel: LessonOccurrenceViewModelProtocol {
    // MARK: - Callbacks
    var onUpdate: (() -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Data
    private(set) var todayOccurrences: [LessonOccurrence] = []
    
    // MARK: - Properties
    private let occurrenceService: OccurrenceFirestoreServiceProtocol
    private let authService: AuthServiceProtocol
    
    // MARK: - Init
    init(
        occurrenceService: OccurrenceFirestoreServiceProtocol = OccurrenceFirestoreService(),
        authService: AuthServiceProtocol = AuthService()
    ) {
        self.occurrenceService = occurrenceService
        self.authService = authService
    }
    
    // MARK: - Fetch
    func fetchTodayOccurrences() {
        guard let userId = authService.currentUserId else {
            onError?("User not authenticated")
            return
        }
        Task {
            do {
                let occurrences = try await occurrenceService
                    .fetchTodayOccurrences(studentId: userId)
                await MainActor.run { [weak self] in
                    self?.todayOccurrences = occurrences
                    self?.onUpdate?()
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    func cancelOccurrences(_ occurrence: LessonOccurrence,
                           by cancelledBy: CancelledBy) {
        guard let id = occurrence.id else { return }
        Task {
            do {
                try await occurrenceService.cancelOccurrence(id: id,
                                                             by: cancelledBy)
                let userId = authService.currentUserId ?? ""
                let occurrences = try await occurrenceService.fetchTodayOccurrences(studentId: userId)
                await MainActor.run { [weak self] in
                    self?.todayOccurrences = occurrences
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
