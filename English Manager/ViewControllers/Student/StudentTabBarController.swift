//
//  StudentTabBarController.swift
//  English Manager
//
//  Created by Sergej Klepikov on 06.03.2026.
//

import UIKit

final class StudentTabBarController: UITabBarController {
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
            makeStudentLessonsTabs(),
            makeHomeworkTab(),
            makePaymentsTab()
        ], animated: false)
        selectedIndex = 1
    }
    
    private func setupAppearance() {
        tabBar.backgroundColor = .appBackground
        tabBar.tintColor = .Brand.primary
        tabBar.unselectedItemTintColor = .Brand.secondary
    }
    
    // MARK: - Tabs
    private func makeProfileTab() -> UINavigationController {
        let nav = makeNav { StudentProfileViewController(router: $0) }
        nav.tabBarItem = UITabBarItem(
            title: "profile".localized,
            image: UIImage(systemName: "person.circle"),
            selectedImage: UIImage(systemName: "person.circle.fill")
        )
        return nav
    }
    
    private func makeStudentLessonsTabs() -> UINavigationController {
        let nav = makeNav { StudentLessonsViewController(router: $0) }
        nav.tabBarItem = UITabBarItem(
            title: "lessons_capitalized".localized,
            image: UIImage(systemName: "calendar"),
            selectedImage: UIImage(systemName: "calendar.fill")
        )
        return nav
    }
    
    private func makeHomeworkTab() -> UIViewController {
        let nav = makeNav { StudentHomeworkViewController(router: $0) }
        nav.tabBarItem = UITabBarItem(
            title: "homework".localized,
            image: UIImage(systemName: "doc.text"),
            selectedImage: UIImage(systemName: "doc.text.fill")
        )
        return nav
    }
    
    private func makePaymentsTab() -> UIViewController {
        let nav = makeNav { StudentPaymentsViewController(router: $0) }
        nav.tabBarItem = UITabBarItem(
            title: "payment".localized,
            image: UIImage(systemName: "creditcard"),
            selectedImage: UIImage(systemName: "creditcard.fill")
        )
        return nav
    }
    
    // MARK: - Helper
    private func makeNav(_ build: (StudentRouter) -> UIViewController
    ) -> UINavigationController {
        let nav = UINavigationController()
        let router = StudentRouter(navigationController: nav,
                                   authRouter: authRouter)
        let vc = build(router)
        nav.viewControllers = [vc]
        return nav
    }
}
