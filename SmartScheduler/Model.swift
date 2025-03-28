//
//  Model.swift
//  SmartScheduler
//
//  Created by Yousef Sandoqa on 3/25/25.
//

import Foundation
import SwiftData

@Model
class Reminder{
    var title: String
    var date: Date
    var desc: String
    var location: String?
    
    init(title: String, date: Date, desc: String, location: String? = nil) {
        self.title = title
        self.desc = desc
        self.date = date
        self.location = location
    }
}
