//
//  NotificationDelegate.swift
//  SmartScheduler
//
//  Created by Yousef Sandoqa and Yosef Pineda
//

import Foundation
import UserNotifications
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
