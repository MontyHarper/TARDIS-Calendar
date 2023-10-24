//
//  EKEventExtension.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 10/21/23.
//

import EventKit
import Foundation

struct Event {
    var id = UUID()
    var startDate: Date
    var endDate: Date
    var title: String
    var calendarTag: String
    
    init(start: Date, end: Date, title: String, calendar: String) {
        self.startDate = start
        self.endDate = end
        self.title = title
        self.calendarTag = calendar
    }
    
}
