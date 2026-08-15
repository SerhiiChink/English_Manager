//
//  TeacherRouter.swift
//  English Manager
//
//  Created by Sergej Klepikov on 25.03.2026.
//

import UIKit

protocol TeacherRouterProtocol: AnyObject {
    func showStudents()
    func showEditProfile(user: User)
    func showScheduleDetail(
        student: User,
        schedules: [Schedule],
        rescheduledLessons: [RescheduledLesson],
        onAdd: @escaping (ScheduleDraft,
                          @escaping (Schedule) -> Void) -> Void,
        onDelete: @escaping (Schedule) -> Void,
        onDeleteRescheduled: @escaping (String) -> Void
    )
    func showHomeworkDetail(
        _ homework: Homework,
        onReview: @escaping (Homework, Int, String) -> Void)
    func showTeacherPayment(student: User)
    func showPaymentReview(
        payment: PaymentRequest,
        settings: TeacherSettings?,
        onConfirm: @escaping () -> Void,
        onReject: @escaping () -> Void,
        onEdit: @escaping (Int, PaymentReviewViewModelProtocol) -> Void)
    func showLogin()
    func showLessonConfirmation(occurrence: LessonOccurrence,
                                student: User,
                                onDismiss: @escaping () -> Void,
                                onSwipeDown: @escaping () -> Void)
}

final class TeacherRouter: TeacherRouterProtocol {
    // MARK: - Properties
    private weak var navigationController: UINavigationController?
    private let authRouter: AuthRouterProtocol
    
    // MARK: - Init
    init(
        navigationController: UINavigationController?,
        authRouter: AuthRouterProtocol
    ) {
        self.navigationController = navigationController
        self.authRouter = authRouter
    }
    
    // MARK: - Navigation
    func showStudents() {
        let vc = StudentsViewController(router: self)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showEditProfile(user: User) {
        let vc = EditProfileViewController(user: user)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showScheduleDetail(
        student: User,
        schedules: [Schedule],
        rescheduledLessons: [RescheduledLesson],
        onAdd: @escaping (ScheduleDraft,
                          @escaping (Schedule) -> Void) -> Void,
        onDelete: @escaping(Schedule) -> Void,
        onDeleteRescheduled: @escaping(String) -> Void
    ) {
        let vc = ScheduleDetailViewController(
            student: student,
            schedules: schedules,
            rescheduledLessons: rescheduledLessons,
            onAdd: onAdd,
            onDelete: onDelete,
            onDeleteRescheduled: onDeleteRescheduled
        )
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showHomeworkDetail(
        _ homework: Homework,
        onReview: @escaping (Homework, Int, String) -> Void
    ) {
        let vc = TeacherHomeworkDetailViewController(homework: homework,
                                                     onReview: onReview)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showTeacherPayment(student: User) {
        let viewModel = TeacherPaymentDetailViewModel(student: student)
        let vc = TeacherPaymentDetailViewController(viewModel: viewModel,
                                                    router: self)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showPaymentReview(
        payment: PaymentRequest,
        settings: TeacherSettings?,
        onConfirm: @escaping () -> Void,
        onReject: @escaping () -> Void,
        onEdit: @escaping (Int, PaymentReviewViewModelProtocol) -> Void) {
        let review = PaymentReviewViewModel(payment: payment,
                                            settings: settings)
        review.onConfirm = onConfirm
        review.onReject = onReject
        review.onEdit = { [weak review] newCount in
            guard let review else { return }
            onEdit(newCount, review)
        }
        let vc = PaymentReviewViewController(viewModel: review)
        navigationController?.topViewController?.presentAsSheet(
            vc,
            detent: .medium()
        )
    }
    
    func showLogin() {
        authRouter.showLogin()
    }
    
    func showLessonConfirmation(occurrence: LessonOccurrence,
                                student: User,
                                onDismiss: @escaping () -> Void,
                                onSwipeDown: @escaping () -> Void) {
        let viewModel = LessonConfirmationViewModel(occurrence: occurrence,
                                                    student: student)
        viewModel.onDismiss = onDismiss
        viewModel.onSwipedDown = onSwipeDown
        let vc = LessonConfirmationViewController(viewModel: viewModel)
        navigationController?.topViewController?.presentAsSheet(
            vc, detent: .medium()
        )
    }
}
