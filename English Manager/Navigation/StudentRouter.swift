//
//  StudentRouter.swift
//  English Manager
//
//  Created by Sergej Klepikov on 25.03.2026.
//

import UIKit

protocol StudentRouterProtocol: AnyObject {
    func showEditProfile(user: User)
    func showLessonDetail(_ lesson: Lesson,
                          teacherName: String?)
    func showLogin()
}

final class StudentRouter: StudentRouterProtocol {
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
    
    func showLessonDetail(_ lesson: Lesson,
                          teacherName: String?) {
        let vc = StudentLessonDetailViewController(lesson: lesson,
                                                   teacherName: teacherName)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showLogin() {
        authRouter.showLogin()
    }
}

