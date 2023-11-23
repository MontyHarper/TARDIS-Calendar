//
//  EventManager.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 10/17/23.
//
//  Captures new events; provides an array of EventViews for the main view.
//

import EventKit
import Foundation
import SwiftUI
import UIKit

// Wrapper for EKEvent, providing a unique id for each event.
// Start time is rounded to the minute; can be used also to identify an event.
class Event: Identifiable, Comparable {
    
    var event: EKEvent
    var type: String
    
    // Track this here for persistance as the views themselves get recycled.
    
    init(event: EKEvent, type: String) {
        self.event = event
        self.type = type
    }
        
    var id: UUID {
        UUID()
    }
    
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
    var priority: Int {
        if let number = CalendarType(rawValue:type)?.priority() {
            return number
        } else {
            return 0
        }
    }
    
    // Protocol conformance for Comparable
    
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


class EventManager: ObservableObject {
    
    @Published var events = [Event]() // Upcoming events for the maximum number of days allowed in the display.
    @Published var isExpanded = [Bool]() // For each event, should the view be rendered as expanded? This is the source of truth for expansion of event views.
    @Published var calendarSet = CalendarSet() // Tracks Apple Calendar calendars and user selected calendars.
    
    let eventStore = EKEventStore()
    
    // newEvents temporarily stores newly downloaded events used to update the event list.
    // This allows updates to preserve event indices so information about the display mode is not overwritten.
    private var newEvents = [Event]()
    
    // Start with a freshly fetched list of events from the user's Apple Calendar app.
    init() {
        // TODO: - Hardcoding this for now; will need to allow user to set this up
        UserDefaults.standard.set(
            ["BenaDaily": CalendarType.daily.rawValue,
             "BenaMedical": CalendarType.medical.rawValue,
             "BenaMeals": CalendarType.meals.rawValue,
             "BenaSpecial": CalendarType.special.rawValue
            ],
            forKey: "calendars")
        refreshCalendarsAndEvents()
        // Notification will update the events list any time an event or calendar is changed in the user's Apple Calendar App.
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshCalendarsAndEvents), name: .EKEventStoreChanged, object: eventStore)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(eventStore)
    }
    
    @objc func refreshCalendarsAndEvents() {
        calendarSet.updateCalendars(eventStore: eventStore) { error in
            if let error = error {
                // TODO: - handle errors gracefully
                fatalError("\(error.title())")
            } else {
                self.updateEvents()
            }
        }
    }
        
    @objc func updateEvents() {
                
        // Set up date parameters
        let start = Timeline.minDay
        let end = Timeline.maxDay
        
        // Set up search predicate
        let findEKEvents = eventStore.predicateForEvents(withStart: start, end: end, calendars: calendarSet.calendarsToSearch)
        
        // Save the dates that are expanded
        let expandedDates = Set(isExpanded.indices.filter({isExpanded[$0]}).map({events[$0].startDate}))
        
        // Store the search results, converting EKEvents to Events, replacing current events.
        newEvents = eventStore.events(matching: findEKEvents).map({ekevent in
            Event(event: ekevent, type: calendarSet.userCalendars[ekevent.calendar.title] ?? "none")
        })
        
        DispatchQueue.main.async {
            self.updateEventsCompletion(expandedDates)
        }
                
    } // End of updateEvents
    
    func updateEventsCompletion(_ expandedDates: Set<Date>) {
        
        events = newEvents
        
        // Filter the results to remove lower priority events scheduled at the same time as higher priority events...
        // TODO: - Test this!
            self.events = self.events.filter({event in
            let sameDate = self.events.filter({$0.startDate == event.startDate})
            return event == sameDate.max()
        })
        
        // Restore dates that are expanded.
            self.isExpanded = self.events.indices.map({expandedDates.contains(self.events[$0].startDate)})
        print("number of events: \(self.events.count)")
        print("number of isExpanded: \(self.isExpanded.count)")
    }
    
    
    // Called when user taps the background; closes any expanded views.
    func closeAll() {
        print("Close All")
        for i in 0..<isExpanded.count {
            isExpanded[i] = false
        }
    }
    
}
