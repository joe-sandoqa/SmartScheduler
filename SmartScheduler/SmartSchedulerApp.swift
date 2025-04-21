//
//  SmartSchedulerApp.swift
//  SmartScheduler
//
//  Created by Yousef Sandoqa and Yosef Pineda
//

import SwiftUI
import MapKit
import SwiftData
import UserNotifications

@main
struct SmartSchedulerApp: App {
    let container: ModelContainer
    init() {
        let schema = Schema([Reminder.self])
        container = try! ModelContainer(for: schema)
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification auth error: \(error.localizedDescription)")
            }
        }
        center.delegate = NotificationDelegate.shared
        ViewModel().checkTodayIsHolidayAndNotify()
        let context = container.mainContext
        registerGeofencesForSavedReminders(context: context)
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
        }
    }
    func registerGeofencesForSavedReminders(context: ModelContext) {
        do {
            let reminders = try context.fetch(FetchDescriptor<Reminder>())
            for reminder in reminders {
                NotificationManager.instance.scheduleGeofenceNotification(for: reminder)
                NotificationManager.instance.scheduleTimedNotification(for: reminder)
            }
        } catch {
            print("Error fetching reminders on app launch: \(error)")
        }
    }
}
