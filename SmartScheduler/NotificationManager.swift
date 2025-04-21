//
//  NotificationManager.swift
//  SmartScheduler
//
//  Created by Yousef Sandoqa and Yosef Pineda
//

import Foundation
import UserNotifications
import CoreLocation

class NotificationManager: NSObject, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    static let instance = NotificationManager()
    private let geofenceManager = CLLocationManager()
    
    private override init() {
        super.init()
        geofenceManager.delegate = self
        geofenceManager.requestAlwaysAuthorization()
        geofenceManager.allowsBackgroundLocationUpdates = true
        geofenceManager.pausesLocationUpdatesAutomatically = false
    }

    
    func scheduleImmediateNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    /// Schedule a 100 m geofence around the reminder location
    func scheduleGeofenceNotification(for reminder: Reminder) {
        guard let lat = reminder.latitude, let lng = reminder.longitude else { return }
        let center = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let region = CLCircularRegion(center: center, radius: 100, identifier: reminder.title)
        region.notifyOnEntry = true
        region.notifyOnExit = false
        geofenceManager.startMonitoring(for: region)
    }

    // CLLocationManagerDelegate callback
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let content = UNMutableNotificationContent()
        content.title = "You're near \(region.identifier)"
        content.body = "You have a reminder for this location."
        content.sound = .default
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    func scheduleTimedNotification(for reminder: Reminder) {
        let date = reminder.date
        
        let content = UNMutableNotificationContent()
        content.title = "Reminder: \(reminder.title)"
        content.body = reminder.desc
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(
            identifier: "timedReminder_\(reminder.id)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling timed reminder: \(error.localizedDescription)")
            }
        }
    }
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            } else {
                print("Notification permission granted? \(success)")
            }
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                if settings.authorizationStatus == .authorized {
                    print("Notification permissions granted.")
                } else {
                    print("Notification permissions not granted.")
                }
            }
        }
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                            willPresent notification: UNNotification,
                            withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    func checkLocationPermissions() {
        let status = geofenceManager.authorizationStatus
        switch status {
        case .notDetermined, .restricted, .denied:
            print("Location permissions not granted")
        case .authorizedAlways, .authorizedWhenInUse:
            print("Location permissions granted")
        @unknown default:
            print("Unknown location authorization status")
        }
    }
}
