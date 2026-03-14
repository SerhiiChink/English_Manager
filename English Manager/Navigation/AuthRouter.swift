//
//  AuthRouter.swift
//  English Manager
//
//  Created by Sergej Klepikov on 06.03.2026.
//

import UIKit

protocol AuthRouterProtocol: AnyObject {
    func showLogin()
    func showRole()
    func showMainScreen(role: UserRole)
}

final class AuthRouter: AuthRouterProtocol {
    // MARK: - Properties
    private let navigationController: UINavigationController
    private let authService: AuthServiceProtocol
    
    // MARK: - Init
    init(
        navigationController: UINavigationController,
        authService: AuthServiceProtocol = AuthService()
    ) {
        self.navigationController = navigationController
        self.authService = authService
    }
    
    func start() {
        showSplash()
    }
    
    // MARK: - Navigation
    func showLogin() {
        let vc = LoginViewController(router: self)
        navigationController.setViewControllers([vc], animated: true)
    }

    func showRole() {
        let vc = RoleViewController(router: self)
        navigationController.setViewControllers([vc], animated: true)
    }

    func showMainScreen(role: UserRole) {
        switch role {
        case .teacher:
            let vc = TeacherTabBarController(router: self)
            navigationController.setViewControllers([vc], animated: true)
        case .student:
            let vc = StudentTabBarController(router: self)
            navigationController.setViewControllers([vc], animated: true)
        }
    }
    
    // MARK: - Helper
    private func showSplash() {
        let vc = SplashViewController(router: self,
                                      authService: authService)
        navigationController.setViewControllers([vc], animated: false)
    }
}
