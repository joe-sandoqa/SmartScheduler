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
        var upcomingReminders: [Reminder] {
        reminders
            .filter { $0.date >= Date() }
            .sorted { $0.date < $1.date }
    }
    var oldReminders: [Reminder] {
        reminders
            .filter { $0.date < Date() }
            .sorted { $0.date > $1.date }
    }
    private var con: ModelContext?
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
        NotificationManager.instance.scheduleTimedNotification(for: newReminder)
        let fmtDate = DateFormatter.localizedString(
            from: date,
            dateStyle: .short,
            timeStyle: .short
        )
        NotificationManager.instance.scheduleImmediateNotification(
            title: "Reminder Created",
            body: "\(title) set for \(fmtDate)"
        )
        NotificationManager.instance.scheduleGeofenceNotification(for: newReminder)
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
                NotificationManager.instance.scheduleImmediateNotification(
                    title: "Today is a holiday!!",
                    body: "\(holiday.localName) is today!"
                )
            }
        }
    }
    func checkNearbyReminders(at coordinate: CLLocationCoordinate2D) {
        guard let ctx = con else { return }
        LocationReminderChecker.checkAndNotify(
            context: ctx,
            currentLocation: coordinate
        )
    }
}
