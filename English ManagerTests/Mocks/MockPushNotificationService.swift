//
//  MockPushNotificationService.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 12.08.2026.
//

import Foundation
@testable import English_Manager

final class MockPushNotificationService: PushNotificationServiceProtocol {
    // MARK: - Properties
    var onTokenRefresh: ((String) -> Void)?
    var onNotificationTap: ((PushNavigationTarget) -> Void)?
    
    // MARK: - Call Trackers
    private(set) var setupCalled = false

    // MARK: - Methods
    func setup() {
        setupCalled = true
    }
    
    // MARK: - Simulation Helpers
    func simulateTokenRefresh(token: String) {
        onTokenRefresh?(token)
    }

    func simulateNotificationTap(target: PushNavigationTarget) {
        onNotificationTap?(target)
    }
}
