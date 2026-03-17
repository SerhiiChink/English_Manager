//
//  TeacherTabBarController.swift
//  English Manager
//
//  Created by Sergej Klepikov on 06.03.2026.
//

import UIKit

final class TeacherTabBarController: UITabBarController {
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
        let lessonsVC = makeLessonsTab()
        let studentsVC = makeStudentsTab()
        let homeworkVC = makeHomeworkTab()
        let paymentsVC = makePaymentsTab()
        setViewControllers(
            [lessonsVC, studentsVC, homeworkVC, paymentsVC],
            animated: false
        )
    }
    
    private func setupAppearance() {
        tabBar.backgroundColor = .appBackground
        tabBar.tintColor = .appAccent
        tabBar.unselectedItemTintColor = .appTextSecondary
    }
    
    // MARK: - Tabs
    private func makeLessonsTab() -> UIViewController {
        let vc = TeacherLessonsViewController(router: router)
        let nav = UINavigationController(rootViewController: vc)
        nav.tabBarItem = UITabBarItem(
            title: "Lessons",
            image: UIImage(systemName: "calendar"),
            selectedImage: UIImage(systemName: "calendar.fill")
        )
        return nav
    }
    
    private func makeStudentsTab() -> UIViewController {
        let vc = StudentsViewController(router: router)
        let nav = UINavigationController(rootViewController: vc)
        nav.tabBarItem = UITabBarItem(
            title: "Students",
            image: UIImage(systemName: "person.2"),
            selectedImage: UIImage(systemName: "person.2.fill")
        )
        return nav
    }
    
    private func makeHomeworkTab() -> UIViewController {
        let vc = TeacherHomeworkViewController(router: router)
        let nav = UINavigationController(rootViewController: vc)
        nav.tabBarItem = UITabBarItem(
            title: "Homework",
            image: UIImage(systemName: "doc.text"),
            selectedImage: UIImage(systemName: "doc.text.fill")
        )
        return nav
    }
    
    private func makePaymentsTab() -> UIViewController {
        let vc = TeacherPaymentsViewController(router: router)
        let nav = UINavigationController(rootViewController: vc)
        nav.tabBarItem = UITabBarItem(
            title: "Payment",
            image: UIImage(systemName: "creditcard"),
            selectedImage: UIImage(systemName: "creditcard.fill")
        )
        return nav
        
    }
}
