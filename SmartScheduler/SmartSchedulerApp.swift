//
//  SmartSchedulerApp.swift
//  SmartScheduler
//
//  Created by Yousef Sandoqa and Yosef Pineda
//

import SwiftUI
import MapKit

@main
struct SmartSchedulerApp: App {
    init() {
        // Request notification permission
        NotificationManager.instance.requestAuthorization()
        // Set the delegate so notifications show when the app is in the foreground.
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        ViewModel().checkTodayIsHolidayAndNotify()
        ViewModel().checkNearbyReminders(at: CLLocationCoordinate2D)
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Reminder.self])
        }
    }
}
