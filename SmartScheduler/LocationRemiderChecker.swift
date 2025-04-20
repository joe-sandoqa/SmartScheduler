//
//  LocationRemiderChecker.swift
//  SmartScheduler
//
//  Created by Yosef Pineda on 4/18/25.
//

import Foundation
import SwiftData
import CoreLocation
import UserNotifications

class LocationReminderChecker {
    static let thresholdDistance: Double = 30.48
    static func checkAndNotify(context: ModelContext, currentLocation: CLLocationCoordinate2D) {
        let currentLoc = CLLocation(latitude: currentLocation.latitude,
                                    longitude: currentLocation.longitude)
        do {
            let reminders: [Reminder] = try context.fetch(FetchDescriptor<Reminder>())
            for reminder in reminders {
                guard let lat = reminder.latitude,
                      let lng = reminder.longitude else {
                    continue
                }
                let reminderLoc = CLLocation(latitude: lat, longitude: lng)
                let distance = currentLoc.distance(from: reminderLoc)
                if distance <= thresholdDistance {
                    let content = UNMutableNotificationContent()
                    content.title = "Nearby Reminder: \(reminder.title)"
                    content.body = reminder.desc
                    content.sound = .default
                    let request = UNNotificationRequest(
                        identifier: "locationReminder_\(reminder.id)",
                        content: content,
                        trigger: nil
                    )
                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error {
                            print("Error scheduling location reminder notification:", error)
                        }
                    }
                }
            }
        } catch {
            print("Error fetching reminders for location check:", error)
        }
    }
}
