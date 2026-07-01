//
//  SceneDelegate.swift
//  English Manager
//
//  Created by Sergej Klepikov on 03.03.2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var router: AuthRouter?
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let authService = AuthService()
        let navigationController = UINavigationController()
        navigationController.isNavigationBarHidden = true
        let router = AuthRouter(
            navigationController: navigationController,
            authService: authService
        )
        self.router = router
        router.start()
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
        setupPushNavigation()
        if let response = connectionOptions.notificationResponse {
            let userInfo = response.notification.request.content.userInfo
            let target = PushNotificationMapper.navigationTarget(from: userInfo)
            router.navigateToPush(target: target)
        }
    }
    
    // MARK: - Private
    private func setupPushNavigation() {
        PushNotificationService.shared.onNotificationTap = { [weak self] target in
            guard let self else { return }
            DispatchQueue.main.async {
                self.router?.navigateToPush(target: target)
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}
}


