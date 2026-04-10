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
    func showSchedulePicker(student: User,
                            onSave: @escaping (ScheduleDraft) -> Void)
    func showHomeworkDetail(
        _ homework: Homework,
        onReview: @escaping (Homework, Int, String) -> Void)
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
    
    func showSchedulePicker(student: User,
                            onSave: @escaping (ScheduleDraft) -> Void) {
        let vc = SchedulePickerViewController(student: student,
                                              onSave: onSave)
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        navigationController?.present(vc, animated: true)
    }
    
    func showHomeworkDetail(
        _ homework: Homework,
        onReview: @escaping (Homework, Int, String) -> Void
    ) {
        let vc = TeacherHomeworkDetailViewController(homework: homework,
                                                     onReview: onReview)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showLogin() {
        authRouter.showLogin()
    }
}
