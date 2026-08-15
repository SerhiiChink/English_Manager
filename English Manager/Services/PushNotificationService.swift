//
//  PushNotificationService.swift
//  English Manager
//
//  Created by Sergej Klepikov on 28.05.2026.
//

import FirebaseMessaging
import UserNotifications

protocol PushNotificationServiceProtocol: AnyObject {
    var onTokenRefresh: ((String) -> Void)? { get set }
    var onNotificationTap: ((PushNavigationTarget) -> Void)? { get set }
    func setup()
}

final class PushNotificationService: NSObject, PushNotificationServiceProtocol {
    // MARK: - Properties
    static let shared: PushNotificationServiceProtocol = PushNotificationService()
    var onTokenRefresh: ((String) -> Void)?
    var onNotificationTap: ((PushNavigationTarget) -> Void)?
    
    // MARK: - Init
    private override init() {
        super.init()
    }
    
    // MARK: - Setup
    func setup() {
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
    }
}

// MARK: - MessagingDelegate
extension PushNotificationService: MessagingDelegate {
    func messaging(_ messaging: Messaging,
                   didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        onTokenRefresh?(token)
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension PushNotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let pushType = extractPushType(from: notification.request.content.userInfo)
        if pushType == .lessonCompleted {
            NotificationCenter.default.post(name: .lessonCompleted,
                                            object: nil)
        }
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let pushType = extractPushType(from: response.notification.request.content.userInfo)
        let target = PushNotificationMapper.navigationTarget(for: pushType)
        onNotificationTap?(target)
        completionHandler()
    }
    
    // MARK: - Private
    private func extractPushType(from userInfo: [AnyHashable: Any]) -> PushType {
        let rawType = userInfo["type"] as? String ?? ""
        return PushType(rawValue: rawType)
    }
}
