//
//  AppDelegate.swift
//  English Manager
//
//  Created by Sergej Klepikov on 03.03.2026.
//

import UIKit
import FirebaseCore
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        setupAppearance()
        let authService: AuthServiceProtocol = AuthService()
        let firestoreService: FirestoreServiceProtocol = FirestoreService()
        setupPushNotifications(application: application,
                               authService: authService,
                               firestoreService: firestoreService)
        return true
    }


    // MARK: UISceneSession Lifecycle
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {}
}

// MARK: - Push Notifications
private extension AppDelegate {
    func setupPushNotifications(
        application: UIApplication,
        authService: AuthServiceProtocol,
        firestoreService: FirestoreServiceProtocol
    ) {
        PushNotificationService.shared.onTokenRefresh = { token in
            guard let userId = authService.currentUserId else { return }
            Task {
                try? await firestoreService.updateFCMToken(userId: userId,
                                                           token: token)
            }
        }
        PushNotificationService.shared.setup()
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, _ in
            guard granted else { return }
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }
}

// MARK: - Global Appearance
private extension AppDelegate {
    func setupAppearance() {
        setupNavigationBarAppearance()
        setupTabBarAppearance()
    }
    
    func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.Brand.primary,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        let buttonAppearance = UIBarButtonItemAppearance()
        buttonAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.Brand.primary
        ]
        appearance.buttonAppearance = buttonAppearance
        appearance.backButtonAppearance = buttonAppearance
        appearance.doneButtonAppearance = buttonAppearance
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = .Brand.primary
    }
    
    func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .appBackground
        appearance.shadowColor = .clear
        [appearance.stackedLayoutAppearance,
         appearance.inlineLayoutAppearance,
         appearance.compactInlineLayoutAppearance].forEach {
            $0.selected.iconColor = .appText
            $0.selected.titleTextAttributes = [.foregroundColor: UIColor.appText]
            $0.normal.iconColor = .appTextSecondary
            $0.normal.titleTextAttributes = [.foregroundColor: UIColor.appText]
        }
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        UITabBar.appearance().tintColor = .label
        UITabBar.appearance().unselectedItemTintColor = .secondaryLabel
    }
}
