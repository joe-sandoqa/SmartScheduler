//
//  NotificationManager.swift
//  SmartScheduler
//
//  Created by Yousef Sandoqa and Yosef Pineda
//

import Foundation
import UserNotifications
import CoreLocation

class NotificationManager: NSObject, CLLocationManagerDelegate {
    static let instance = NotificationManager()
    private let geofenceManager = CLLocationManager()
    
    private override init() {
        super.init()
        geofenceManager.delegate = self
        geofenceManager.requestAlwaysAuthorization()
    }
    
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            } else {
                print("Notification permission granted? \(success)")
            }
        }
    }
    
    func scheduleNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        // Trigger after 1 second for an immediate notification.
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
}
