//
//  EventManager.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 10/17/23.
//
//  Captures new events; provides an array of Event view models.
//

import EventKit
import Foundation
import SwiftUI
import UIKit

// Event is a wrapper for EKEvent, Event Kit's raw event Type.
// - Provides a type for each event
// - Provides a unique id for each event
// - Conforms events to Idenditfiable and Comparable protocols
// - Rounds starting time so it can be used as an alternate identification (No two events should start at the same time.)
// - Exposes various other values.

class Event: Identifiable, Comparable {
    
    var event: EKEvent
    var type: String
        
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


// ContentView uses an instance of EventManager to access current events, calendars, and related info.
class EventManager: ObservableObject {
    
    var eventStore = EKEventStore()
    
    @Published var events = [Event]() // Upcoming events for the maximum number of days displayed.
    @Published var isExpanded = [Bool]() // For each event, should the view be rendered as expanded? This is the source of truth for expansion of event views.
    @Published var calendarSet = CalendarSet() // Tracks which of Apple's Calendar App calendars we're drawing events from.
    
    // newEvents temporarily stores newly downloaded events so that events can be replaced with newEvents on the main thread.
    private var newEvents = [Event]()
    
    init() {
        // Notification will update the calendars and events lists any time an event or calendar is changed in the user's Apple Calendar App.
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCalendarsAndEvents), name: .EKEventStoreChanged, object: eventStore)
        
        if StateBools.shared.noPermissionForCalendar {
            // App will request access to the Apple Calendar. If the user refuses, the system will not show the request again.
            // This syntax is deprecated but I can't run the latest XCode on my old-ass computer.
            // TODO: - Buy a new iMac, install OS13, install xCode 15, and update this line.
            eventStore.requestAccess(to: EKEntityType.event) {_,_ in }
            // If permission is newly given, the notification above will fetch new data.
        } else {
            // If permission is already given, fetch new data.
            updateCalendarsAndEvents()
        }

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(eventStore)
    }
    
    @objc func updateCalendarsAndEvents() {
        calendarSet.updateCalendars(eventStore: eventStore) { error in
            if let error = error {
                StateBools.shared.noCalendarsAvailable = (error == CalendarError.noAppleCalendars)
            } else {
                StateBools.shared.noCalendarsAvailable = false
                self.updateEvents() // Called from within closure to ensure calendars are updated first.
            }
        }
    }
        
    func updateEvents() {
                
        // Set up date parameters
        let start = Timeline.minDay
        let end = Timeline.maxDay
        
        // Set up search predicate
        let findEKEvents = eventStore.predicateForEvents(withStart: start, end: end, calendars: calendarSet.calendarsToSearch)
        
        // Save which dates are shown in expanded view.
        let expandedDates = Set(isExpanded.indices.filter({isExpanded[$0]}).map({events[$0].startDate}))
        
        // Store the search results, converting EKEvents to Events, replacing current events.
        newEvents = eventStore.events(matching: findEKEvents).map({ekevent in
            Event(event: ekevent, type: calendarSet.userCalendars[ekevent.calendar.title] ?? "none")
        })
        
        // events has to be updated on the main queue.
        DispatchQueue.main.async {
            self.updateEventsCompletion(expandedDates)
        }
                
    } // End of updateEvents
    
    func updateEventsCompletion(_ expandedDates: Set<Date>) {
        
        if calendarSet.calendarsToSearch.count > 0 {
            
            events = newEvents
            StateBools.shared.noCalendarsSelected = false
            
        } else {
            // No calendars have been selected. This means we had an empty search predicate, which returned events from all calendars. We don't want the user to see unrelated events from the Caregiver's personal calendars! So this will not be allowed; calendars must be selected before any events are shown.
            events = []
            StateBools.shared.noCalendarsSelected = true
        }
        
        // Filter the results to remove lower priority events scheduled at the same time as higher priority events...
        // TODO: - Test this!
            self.events = self.events.filter({event in
            let sameDate = self.events.filter({$0.startDate == event.startDate})
            return event == sameDate.max()
        })
        
        // Restore dates that are expanded.
            self.isExpanded = self.events.indices.map({expandedDates.contains(self.events[$0].startDate)})
    }
    
    // Called when user taps the background; closes any expanded views.
    func closeAll() {
        print("Close All")
        for i in 0..<isExpanded.count {
            isExpanded[i] = false
        }
    }
    
}
