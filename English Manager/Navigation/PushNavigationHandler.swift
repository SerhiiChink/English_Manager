//
//  PushNavigationHandler.swift
//  English Manager
//
//  Created by Sergej Klepikov on 29.06.2026.
//

import UIKit

protocol PushNavigationHandlerProtocol {
    func navigate(to target: PushNavigationTarget)
}

protocol PushNavigationProviding: UITabBarController {
    var pushNavigationHandler: PushNavigationHandlerProtocol { get }
}

// MARK: - Teacher
final class TeacherPushNavigationHandler: PushNavigationHandlerProtocol {
    private weak var tabBar: UITabBarController?
    
    init(tabBar: UITabBarController) {
        self.tabBar = tabBar
    }
    
    func navigate(to target: PushNavigationTarget) {
        switch target {
        case .payments: tabBar?.selectedIndex = 4
        case .lessons:  tabBar?.selectedIndex = 1
        case .none:     break
        }
    }
}

// MARK: - Student
final class StudentPushNavigationHandler: PushNavigationHandlerProtocol {
    private weak var tabBar: UITabBarController?
    
    init(tabBar: UITabBarController) {
        self.tabBar = tabBar
    }
    
    func navigate(to target: PushNavigationTarget) {
        switch target {
        case .payments: tabBar?.selectedIndex = 3
        case .lessons:  tabBar?.selectedIndex = 1
        case .none:     break
        }
    }
}
