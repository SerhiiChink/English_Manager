//
//  LessonConfirmationViewModel.swift
//  English Manager
//
//  Created by Sergej Klepikov on 26.07.2026.
//

import Foundation

protocol LessonConfirmationViewModelProtocol: AnyObject {
    var occurrence: LessonOccurrence { get }
    var student: User { get }
    var onDismiss: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var onSwipedDown: (() -> Void)? { get set }
    func chargeLesson()
    func missedLesson()
    func cancelLesson(customDate: Date?)
}

final class LessonConfirmationViewModel: LessonConfirmationViewModelProtocol {
    // MARK: - Callbacks
    var onDismiss: (() -> Void)?
    var onError: ((String) -> Void)?
    var onSwipedDown: (() -> Void)?
    
    // MARK: - Data
    let occurrence: LessonOccurrence
    let student: User
    
    // MARK: - Properties
    private let occurrenceService: OccurrenceFirestoreServiceProtocol

    // MARK: - Init
    init(occurrence: LessonOccurrence,
         student: User,
         occurrenceService: OccurrenceFirestoreServiceProtocol = OccurrenceFirestoreService()) {
        self.occurrence = occurrence
        self.student = student
        self.occurrenceService = occurrenceService
    }
    
    // MARK: - Lesson Confirmation
    func chargeLesson() {
        resolveConfirmation(status: .charged)
    }
    
    func missedLesson() {
        resolveConfirmation(status: .missed)
    }
    
    func cancelLesson(customDate: Date? = nil) {
        guard let id = occurrence.id else { return }
        Task {
            do {
                if let date = customDate {
                    var oneTime = occurrence
                    oneTime.id = nil
                    oneTime.scheduleId = nil
                    oneTime.scheduledAt = date
                    oneTime.status = .scheduled
                    try await occurrenceService.createOneTimeOccurrence(oneTime)
                }
                try await occurrenceService.resolveOccurrence(
                    id: id,
                    status: .cancelled
                )
                await MainActor.run { [weak self] in
                    self?.onDismiss?()
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Private
    private func resolveConfirmation(status: OccurrenceStatus) {
        guard let id = occurrence.id else { return }
        Task {
            do {
                try await occurrenceService.resolveOccurrence(id: id,
                                                              status: status)
                await MainActor.run { [weak self] in
                    self?.onDismiss?()
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
}
