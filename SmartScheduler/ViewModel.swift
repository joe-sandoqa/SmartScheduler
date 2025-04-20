//
//  ViewModel.swift
//  SmartScheduler
//
//  Created by Yousef Sandoqa and Yosef Pineda
//

import Foundation
import SwiftData
import Combine
import CoreLocation

class ViewModel: ObservableObject {
    @Published var reminders: [Reminder] = []
    
    private var con: ModelContext?
    
    // No-argument initializer to support @StateObject
    init() { }
    
    func setContext(context: ModelContext) {
        self.con = context
    }
    
    func getReminders() {
        guard let con = con else { return }
        do {
            reminders = try con.fetch(FetchDescriptor<Reminder>())
        } catch {
            print("Error fetching reminders: \(error)")
        }
    }
    
    func addReminder(title: String, desc: String, date: Date, location: String?) {
        guard let con = con else { return }
        let newReminder = Reminder(title: title, date: date, desc: desc, location: location)
        con.insert(newReminder)
        saveContext()
        
        // Schedule local notification to confirm event creation
        let notificationTitle = "Smart Scheduler"
        let notificationBody = "REMINDER: \(title)\n\(desc)"
        NotificationManager.instance.scheduleNotification(title: notificationTitle, body: notificationBody)
    }
    
    func deleteTask(reminder: Reminder) {
        guard let con = con else { return }
        con.delete(reminder)
        saveContext()
    }
    
    func updateTask(reminder: Reminder, title: String, desc: String, date: Date, location: String?) {
        reminder.title = title
        reminder.desc = desc
        reminder.date = date
        reminder.location = location
        saveContext()
    }
    
    private func saveContext() {
        guard let con = con else { return }
        do {
            try con.save()
            getReminders()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    func checkTodayIsHolidayAndNotify() {
        HolidayAPIManager.shared.fetchHolidays { holidays in
            let today = ISO8601DateFormatter().string(from: Date()).prefix(10)
            //let today = "2025-07-04" //this line is for testing
            if let holiday = holidays.first(where: { $0.date == today }) {
                NotificationManager.instance.scheduleNotification(
                    title: "Today is a holiday!!",
                    body: "\(holiday.localName) is today!"
                )
            }
        }
    }
    
    /// Check and notify for any reminders within ~100 ft of the given coordinate.
    func checkNearbyReminders(at coordinate: CLLocationCoordinate2D) {
        guard let ctx = con else { return }
        // Manual test coordinate:
        let testCoordinate = CLLocationCoordinate2D(latitude: 33.424564, longitude: -111.928100)
        LocationReminderChecker.checkAndNotify(context: ctx, currentLocation: testCoordinate)
        
        LocationReminderChecker.checkAndNotify(
            context: ctx,
            currentLocation: coordinate
        )
    }

}
