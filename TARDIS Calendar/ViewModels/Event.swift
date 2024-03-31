//
//  Event.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 1/20/24.
//

import EventKit
import Foundation
import SwiftUI

// Event is a wrapper for EKEvent, Event Kit's raw event Type.
// - Provides a type for each event
// - Provides a unique id for each event
// - Conforms events to Idenditfiable and Comparable protocols
// - Rounds starting time so it can be used as an alternate identification (No two events should start at the same time.)
// - Exposes various other values.

struct Event: Identifiable, Comparable {
    
    var event: EKEvent
    var type: CalendarType
                
    init(event: EKEvent, type: CalendarType) {
        self.event = event
        self.type = type
    }
    
    // To conform to Identifiable & used to determine which event views are expanded
    let id = UUID()
    
    var startDate: Date {
        // Ensures start time is rounded to the minute.
        let components = Timeline.calendar.dateComponents([.year,.month,.day,.hour,.minute], from: event.startDate)
        return Timeline.calendar.date(from: components)!
    }
    var endDate: Date {
        event.endDate
    }
    var title: String {
        event.title
    }
    var calendarTitle: String {
        event.calendar.title
    }
    var calendarColor: Color {
        let cg = event.calendar.cgColor ?? CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
        return Color(cgColor: cg)
    }
    
    // Each calendar type has an associated icon in the CalendarType enum.
    // Use the "daily" icon as a default in case something goes wrong.
    var calendarIcon: Image {
        type.icon()
    }
    
    var priority: Int {
        type.priority()
    }
    
    var happensWhen: String {
        let eventDay = Timeline.calendar.component(.day, from: startDate)
        let today = Timeline.calendar.component(.day, from: Date())
        let eventIsToday: Bool = (eventDay == today)
        let eventIsTomorrow: Bool = (eventDay == (today + 1))
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        let dayOfWeek = formatter.string(from: event.startDate)
        let dayText = eventIsToday ? " Today" : (eventIsTomorrow ? " Tomorrow" : " \(dayOfWeek)")
        return ("at " + event.startDate.formatted(date: .omitted, time: .shortened) + dayText)
    }
    var isNow: Bool {
        (event.startDate...event.endDate).contains(Date())
    }
    
    // MARK: - Options for calculating a relative time description
    
    // I have several different functions to describe time remaining. I will keep them all until I settle on one.
    
    
    var timeRemaining: String {
        var dayString = ""
        var hourString = ""
        var minuteString = ""
        let parts = Timeline.calendar.dateComponents([.day, .hour, .minute], from: Date(), to: event.startDate)
        if let day = parts.day {
            dayString = day == 0 ? "" : ("\(day) day" + (day == 1 ? ", " : "s, "))
        }
        if let hour = parts.hour {
            hourString = hour == 0 ? "" : ("\(hour) hour" + (hour == 1 ? ", " : "s, "))
        }
        if let minute = parts.minute {
            minuteString = minute == 0 ? "less than one minute" : ("\(minute) minute" + (minute == 1 ? "." : "s."))
        }
        return(dayString + hourString + minuteString)
    }
    
    
    // This seems to be the simplest description of time remaining, both in execution and format. However, it isn't very accurate - it will say one hour when it's one hour 55 minutes.
    var relativeTimeRemainingDescription: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: event.startDate, relativeTo: Date())
    }
    var relativeTimeRemainingInEvent: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        let timeString = formatter.localizedString(for: event.endDate, relativeTo: Date())
        return timeString.dropFirst().dropFirst().dropFirst() + " remaining\n"
    }
    
    
    // I'm thinking this works better than the others; gives a more accurate estimate, and works either for time "from now" or time "remaining" in an event.
    
    func relativeTimeDescription(_ date: Date, from now: Date) -> String {
        guard event.endDate > now else {
            return ""
        }
        
        let components = Timeline.calendar.dateComponents([.day, .hour, .minute], from: now, to: event.startDate > Date() ? event.startDate : event.endDate)
        
        let days = components.day ?? 0
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        var description = ""
        
        if days >= 1 {
            let plural = (days == 1) ? "" : "s"
            switch hours {
            case 0..<3:
                description += "about \(days.lowerName()) day" + plural
            case 3..<9:
                description += "more than \(days.lowerName()) day" + plural
            case 9..<15:
                description += "about \(days.lowerName()) and a half days"
            case 15..<21:
                description += "less than \((days + 1).lowerName()) days"
            case 21..<24:
                description += "about \((days + 1).lowerName()) days"
            default:
                description += "\(days.lowerName()) day" + plural
            }
        } else if hours >= 1 {
            let plural = (hours == 1) ? "" : "s"
            switch hours {
            case 0..<11:
                switch minutes {
                case 0..<5:
                    description += "about \(hours.lowerName()) hour" + plural
                case 5..<20:
                    description += "more than \(hours.lowerName()) hour" + plural
                case 20..<40:
                    description += "about \(hours.lowerName()) and a half hours"
                case 40..<55:
                    description += "less than \((hours + 1).lowerName()) hours"
                case 55..<60:
                    description += "about \((hours + 1).lowerName()) hours"
                default:
                    description += "\(hours.lowerName()) hour" + plural
                }
            case 11..<13:
                description += "about half a day"
            case 13..<22:
                description += "less than a day"
            case 22..<24:
                description += "about one day"
            default:
                description += "\(hours.lowerName()) hour" + plural
            }
        } else {
            let plural = (minutes == 0) ? "" : "s"
            switch minutes {
            case 0..<20:
                description += "less than \((minutes + 1).lowerName()) minute" + plural
            case 20..<40:
                description += "about half an hour"
            case 40..<55:
                description += "less than an hour"
            case 55..<60:
                description += "about an hour"
            default:
                description += "less than \((minutes + 1).lowerName()) minute" + plural
            }
        }
        return description + (event.startDate > now ? " from now" : " remaining")
    }
    
    
    // MARK: - Comparable Conformance
    
    static func < (lhs: Event, rhs: Event) -> Bool {
        if lhs.startDate < rhs.startDate {
            return true
        } else if lhs.startDate > rhs.startDate {
            return false
        } else {
            return lhs.priority < rhs.priority
        }
    }
    
    static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.startDate == rhs.startDate && lhs.priority == rhs.priority
    }

}
