//
//  AnimatedSplashViewModelTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 15.08.2026.
//

import XCTest
@testable import English_Manager

final class AnimatedSplashViewModelTests: XCTestCase {
    // MARK: - Properties
    private var sut: AnimatedSplashViewModel!
    
    // MARK: - Lifecycle
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    func testStartTappedTriggersOnFinishWithCorrectRole() {
        sut = AnimatedSplashViewModel(role: .teacher)
        var finishedRole: UserRole?
        sut.onFinish = { finishedRole = $0 }

        sut.startTapped()

        XCTAssertEqual(finishedRole, .teacher)
    }

    func testStartTriggersOnReadyToStartCallback() {
        sut = AnimatedSplashViewModel(role: .student, delay: 0.1)
        let exp = expectation(description: "onReadyToStart triggered")
        sut.onReadyToStart = { exp.fulfill() }
        sut.start()
        waitForExpectations(timeout: 4.0)
    }
}
