//
//  ViewModel.swift
//  SmartScheduler
//
//  Created by Yousef Sandoqa on 3/25/25.
//

import Foundation
import SwiftData
import Combine

class ViewModel {
    @Published var reminders: [Reminder] = []
    private var con: ModelContext
    
    init(con: ModelContext) {
        self.con = con
        getReminders()
    }
    func getReminders() {
        do {
            reminders = try con.fetch(FetchDescriptor<Reminder>())
        } catch {
            print("Error fetching reminders: \(error)")
        }
    }
    func addReminder(title: String, desc: String, date: Date, location: String?){
        let newReminder = Reminder(title: title, date: date, desc: desc, location: location)
        con.insert(newReminder)
        saveContext()
    }
    func deleteTask(reminder: Reminder) {
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
        do {
            try con.save()
            getReminders()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
