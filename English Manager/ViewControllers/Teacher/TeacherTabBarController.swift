//
//  TeacherTabBarController.swift
//  English Manager
//
//  Created by Sergej Klepikov on 06.03.2026.
//

import UIKit

final class TeacherTabBarController: UITabBarController {
    // MARK: - Properties
    private let authRouter: AuthRouterProtocol
    
    // MARK: - Init
    init(authRouter: AuthRouterProtocol) {
        self.authRouter = authRouter
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupAppearance()
    }
    
    // MARK: - Setup
    private func setupTabs() {
        setViewControllers([
            makeProfileTab(),
            makeLessonsTab(),
            makeStudentsTab(),
            makeHomeworkTab(),
            makePaymentsTab()
        ], animated: false)
    }
    
    private func setupAppearance() {
        tabBar.backgroundColor = .appBackground
        tabBar.tintColor = .appAccent
        tabBar.unselectedItemTintColor = .appTextSecondary
    }
    
    // MARK: - Tabs
    private func makeProfileTab() -> UIViewController {
        let nav = makeNav { TeacherProfileViewController(router: $0) }
        nav.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person.circle"),
            selectedImage: UIImage(systemName: "person.circle.fill")
        )
        return nav
    }
    
    private func makeLessonsTab() -> UIViewController {
        let nav = makeNav { TeacherLessonsViewController(router: $0) }
        nav.tabBarItem = UITabBarItem(
            title: "Lessons",
            image: UIImage(systemName: "calendar"),
            selectedImage: UIImage(systemName: "calendar.fill")
        )
        return nav
    }
    
    private func makeStudentsTab() -> UIViewController {
        let nav = makeNav { StudentsViewController(router: $0) }
        nav.tabBarItem = UITabBarItem(
            title: "Students",
            image: UIImage(systemName: "person.2"),
            selectedImage: UIImage(systemName: "person.2.fill")
        )
        return nav
    }
    
    private func makeHomeworkTab() -> UIViewController {
        let nav = makeNav { TeacherHomeworkViewController(router: $0) }
        nav.tabBarItem = UITabBarItem(
            title: "Homework",
            image: UIImage(systemName: "doc.text"),
            selectedImage: UIImage(systemName: "doc.text.fill")
        )
        return nav
    }
    
    private func makePaymentsTab() -> UIViewController {
        let nav = makeNav { TeacherPaymentsViewController(router: $0) }
        nav.tabBarItem = UITabBarItem(
            title: "Payment",
            image: UIImage(systemName: "creditcard"),
            selectedImage: UIImage(systemName: "creditcard.fill")
        )
        return nav
    }
    
    // MARK: - Helper
    private func makeNav(_ build: (TeacherRouter) -> UIViewController
    ) -> UINavigationController {
        let nav = UINavigationController()
        let router = TeacherRouter(navigationController: nav,
                                   authRouter: authRouter)
        let vc = build(router)
        nav.viewControllers = [vc]
        return nav
    }
}
