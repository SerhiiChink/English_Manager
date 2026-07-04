//
//  AuthRouter.swift
//  English Manager
//
//  Created by Sergej Klepikov on 06.03.2026.
//

import UIKit

protocol AuthRouterProtocol: AnyObject {
    func showLogin()
    func showSplash()
    func showRole()
    func showMainScreen(role: UserRole)
    func showRoleConfirmation(role: UserRole)
    func showAnimatedSplash(role: UserRole)
    func navigateToPush(target: PushNavigationTarget)
}

final class AuthRouter: AuthRouterProtocol {
    // MARK: - Properties
    private let navigationController: UINavigationController
    private let authService: AuthServiceProtocol
    private let firestoreService: FirestoreServiceProtocol
    private var pendingPushTarget: PushNavigationTarget?
    
    // MARK: - Init
    init(
        navigationController: UINavigationController,
        authService: AuthServiceProtocol = AuthService(),
        firestoreService: FirestoreServiceProtocol = FirestoreService()
    ) {
        self.navigationController = navigationController
        self.authService = authService
        self.firestoreService = firestoreService
    }
    
    func start() {
        showSplash()
    }
    
    // MARK: - Navigation
    func showLogin() {
        let vc = LoginViewController(router: self)
        navigationController.setViewControllers([vc], animated: true)
    }
    
    func showSplash() {
        let viewModel = SplashViewModel(authService: authService,
                                        firestoreService: firestoreService)
        let vc = SplashViewController(router: self, viewModel: viewModel)
        navigationController.setViewControllers([vc], animated: false)
    }

    func showRole() {
        let vc = RoleViewController(router: self)
        navigationController.setViewControllers([vc], animated: true)
    }

    func showMainScreen(role: UserRole) {
        switch role {
        case .teacher:
            let vc = TeacherTabBarController(authRouter: self)
            navigationController.setViewControllers([vc], animated: true)
            if let target = pendingPushTarget {
                pendingPushTarget = nil
                executeNavigation(to: vc, target: target)
            }
        case .student:
            let vc = StudentTabBarController(authRouter: self)
            navigationController.setViewControllers([vc], animated: true)
            if let target = pendingPushTarget {
                pendingPushTarget = nil
                executeNavigation(to: vc, target: target)
            }
        }
    }
    
    func showRoleConfirmation(role: UserRole) {
        let viewModel = RoleConfirmViewModel(role: role)
        let vc = RoleConfirmViewController(router: self,
                                           viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showAnimatedSplash(role: UserRole) {
        let viewModel = AnimatedSplashViewModel(role: role)
        let vc = AnimatedSplashViewController(router: self,
                                      viewModel: viewModel)
        navigationController.setViewControllers([vc], animated: true)
    }
    
    func navigateToPush(target: PushNavigationTarget) {
        guard let tabBar = navigationController.viewControllers.first(
            where: { $0 is UITabBarController }
        ) as? UITabBarController else {
            pendingPushTarget = target
            return
        }
        executeNavigation(to: tabBar, target: target)
    }
    
    // MARK: - Private
    private func executeNavigation(to tabBar: UITabBarController,
                                   target: PushNavigationTarget) {
       (tabBar as? PushNavigationProviding)?
            .pushNavigationHandler
            .navigate(to: target)
    }
}
