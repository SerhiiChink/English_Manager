//
//  StudentTabBarController.swift
//  English Manager
//
//  Created by Sergej Klepikov on 06.03.2026.
//

import UIKit

final class StudentTabBarController: UITabBarController {
    // MARK: - Properties
    private weak var router: AuthRouterProtocol?
    
    // MARK: - Init
    init(
        router: AuthRouterProtocol
    ) {
        self.router = router
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
        let lessonsVC = makeStudentLessonsTabs()
        let homeworkVC = makeHomeworkTab()
        let paymentsVC = makePaymentsTab()
        setViewControllers(
            [lessonsVC, homeworkVC, paymentsVC],
            animated: false
        )
    }
    
    private func setupAppearance() {
        tabBar.backgroundColor = .appBackground
        tabBar.tintColor = .appAccent
        tabBar.unselectedItemTintColor = .appTextSecondary
    }
    
    // MARK: - Tabs
    private func makeStudentLessonsTabs() -> UIViewController {
        let vc = StudentLessonsViewController(router: router)
        let nav = UINavigationController(rootViewController: vc)
        nav.tabBarItem = UITabBarItem(
            title: "Lessons",
            image: UIImage(systemName: "calendar"),
            selectedImage: UIImage(systemName: "calendar.fill")
        )
        return nav
    }
    
    private func makeHomeworkTab() -> UIViewController {
        let vc = StudentHomeworkViewController(router: router)
        let nav = UINavigationController(rootViewController: vc)
        nav.tabBarItem = UITabBarItem(
            title: "Homework",
            image: UIImage(systemName: "doc.text"),
            selectedImage: UIImage(systemName: "doc.text.fill")
        )
        return nav
    }
    
    private func makePaymentsTab() -> UIViewController {
        let vc = StudentPaymentsViewController(router: router)
        let nav = UINavigationController(rootViewController: vc)
        nav.tabBarItem = UITabBarItem(
            title: "Payment",
            image: UIImage(systemName: "creditcard"),
            selectedImage: UIImage(systemName: "creditcard.fill")
        )
        return nav
    }
}
