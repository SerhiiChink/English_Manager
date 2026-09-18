//
//  PushNotificationMapperTests.swift
//  English ManagerTests
//
//  Created by Sergej Klepikov on 16.09.2026.
//

import XCTest
@testable import English_Manager

@MainActor
final class PushNotificationMapperTests: XCTestCase {
    // MARK: - PushType Init Tests
    func testPushTypeInitWithValidRawValuesCreatesCorrectType() {
        XCTAssertEqual(PushType(rawValue: "payment_pending"), .paymentPending)
        XCTAssertEqual(PushType(rawValue: "balance_empty"), .balanceEmpty)
        XCTAssertEqual(PushType(rawValue: "lesson_reminder"), .lessonReminder)
        XCTAssertEqual(PushType(rawValue: "lesson_completed"), .lessonCompleted)
        XCTAssertEqual(PushType(rawValue: "lesson_rescheduled"), .lessonRescheduled)
    }

    func testPushTypeInitWithInvalidRawValueReturnsUnknown() {
        XCTAssertEqual(PushType(rawValue: "invalid_type"), .unknown)
        XCTAssertEqual(PushType(rawValue: ""), .unknown)
    }

    // MARK: - Navigation Target for PushType Tests
    func testNavigationTargetForTypeReturnsCorrectTarget() {
        XCTAssertEqual(PushNotificationMapper.navigationTarget(for: .paymentPending), .payments)
        XCTAssertEqual(PushNotificationMapper.navigationTarget(for: .balanceEmpty), .payments)
        XCTAssertEqual(PushNotificationMapper.navigationTarget(for: .lessonReminder), .lessons)
        XCTAssertEqual(PushNotificationMapper.navigationTarget(for: .lessonCompleted), .lessons)
        XCTAssertEqual(PushNotificationMapper.navigationTarget(for: .lessonRescheduled), .lessons)
        XCTAssertEqual(PushNotificationMapper.navigationTarget(for: .unknown), .none)
    }

    // MARK: - Navigation Target from UserInfo Tests
    func testNavigationTargetFromUserInfoWithValidTypeReturnsCorrectTarget() {
        let userInfo: [AnyHashable: Any] = ["type": "payment_pending"]
        XCTAssertEqual(PushNotificationMapper.navigationTarget(from: userInfo), .payments)

        let lessonUserInfo: [AnyHashable: Any] = ["type": "lesson_reminder"]
        XCTAssertEqual(PushNotificationMapper.navigationTarget(from: lessonUserInfo), .lessons)
    }

    func testNavigationTargetFromUserInfoWithMissingOrInvalidTypeReturnsNone() {
        let emptyUserInfo: [AnyHashable: Any] = [:]
        XCTAssertEqual(PushNotificationMapper.navigationTarget(from: emptyUserInfo), .none)

        let invalidUserInfo: [AnyHashable: Any] = ["type": "something_else"]
        XCTAssertEqual(PushNotificationMapper.navigationTarget(from: invalidUserInfo), .none)
    }
}
