//
//  TeacherRouter.swift
//  English Manager
//
//  Created by Sergej Klepikov on 25.03.2026.
//

import UIKit

protocol TeacherRouterProtocol: AnyObject {
    func showEditProfile(user: User)
//    func showLessonDetail(_ lesson: Lesson)
    func showScheduleDetail(
        student: User,
        schedules: [Schedule],
        onAdd: @escaping (ScheduleDraft) -> Void,
        onDelete: @escaping(Schedule) -> Void,
        onToggleAutoDebit: @escaping (Bool) -> Void
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
    func showEditProfile(user: User) {
        let vc = EditProfileViewController(user: user)
        navigationController?.pushViewController(vc, animated: true)
    }
    
//    func showLessonDetail(_ lesson: Lesson) {
//        let vc = StudentLessonDetailViewController(lesson: lesson)
//        navigationController?.pushViewController(vc, animated: true)
//    }
    
    func showScheduleDetail(
        student: User,
        schedules: [Schedule],
        onAdd: @escaping (ScheduleDraft) -> Void,
        onDelete: @escaping(Schedule) -> Void,
        onToggleAutoDebit: @escaping (Bool) -> Void
    ) {
        let vc = ScheduleDetailViewController(
            student: student,
            schedules: schedules,
            onAdd: onAdd,
            onDelete: onDelete,
            onToggleAutoDebit: onToggleAutoDebit)
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
        review.onEdit = { newCount in
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
}
