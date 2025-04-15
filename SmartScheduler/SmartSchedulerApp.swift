//
//  SmartSchedulerApp.swift
//  SmartScheduler
//
//  Created by Yousef Sandoqa and Yosef Pineda
//

import SwiftUI

@main
struct SmartSchedulerApp: App {
    init() {
        // Request notification permission
        NotificationManager.instance.requestAuthorization()
        // Set the delegate so notifications show when the app is in the foreground.
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        ViewModel().checkTodayIsHolidayAndNotify()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Reminder.self])
        }
    }
}
