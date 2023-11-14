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
    
    // Track this here for persistance as the views themselves get recycled.
    
    init(event: EKEvent) {
        self.event = event
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
        let calendars = UserDefaults.standard.dictionary(forKey: "calendars")
        return CalendarType(rawValue: calendars?[calendarTitle] as! String)?.priority() ?? 0
    }
    
    
    
    // Protocol conformance for comparable
    
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
    @Published var isExpanded = [Bool]() // For each event, should the view be rendered as expanded?

    private let eventStore = EKEventStore()
    
    // Temporarily stores newly downloaded events used to update the event list.
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
        updateEvents()
        // Notification will update the events list any time an event is changed in the user's calendar app.
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateEvents), name: .EKEventStoreChanged, object: eventStore)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(eventStore)
    }
    
    // This method updates the array of events.
    // Is called once per day from the content view.
    // Also is called whenever the user adds or updates events in the calendar.
    // Updates all events, replacing the current list with a new list.
    
    @objc func updateEvents() {
        
        print("update events is called")
        eventStore.requestAccess(to: EKEntityType.event) {granted, error in
            
            if granted {
                
                // Create a list of calendars to search
                var calendarsToSearch = [EKCalendar]()
                let calendars = self.eventStore.calendars(for: .event)
                if let myCalendars = UserDefaults.standard.dictionary(forKey: "calendars") {
                    let myCalendarTitles = myCalendars.keys
                    calendarsToSearch = calendars.filter({myCalendarTitles.contains($0.title)})
                } else {
                    print("No calendars found for this user.")
                    // TODO: - Handle a "no calendars found" event gracefully
                }
                
                // Set up date parameters
                let start = Timeline.minDay
                let end = Timeline.maxDay
                
                // Set up search predicate
                let findEKEvents = self.eventStore.predicateForEvents(withStart: start, end: end, calendars: calendarsToSearch)
                
                // Store the search results
                self.newEvents = self.eventStore.events(matching: findEKEvents).map({ekevent in
                    Event(event: ekevent)
                })
                
                // Filter the search results to remove lower priority events scheduled at the same time as higher priority events...
                // TODO: - Test this!
                self.newEvents = self.newEvents.filter({event in
                    let sameDate = self.newEvents.filter({$0.startDate == event.startDate})
                    return event == sameDate.max()
                })
                
                DispatchQueue.main.async {self.processNewEvents()}
                
            } else {
                print(error as Any)
                print("Permission not granted to fetch events.")
            }
        }
    }
    
    func processNewEvents() {
        print("Processing New Events.")
        
        guard newEvents.count > 0 else {
            return
        }
        
        // Cycle through events from last to first to remove any that have been deleted and update any that already exist.
        if events.count > 0 {
            let last = events.count - 1
            for index in stride(from: last, through: 0, by: -1) {
                let startDate = events[index].startDate
                if newEvents.firstIndex(where: {$0.startDate == startDate}) != nil {
                    // This event already exists; update the event.
                    events[index].event.refresh()
                }
                else {
                    // This event has been deleted so remove it from events.
                    isExpanded.remove(at: index)
                    events.remove(at: index)
                }
            }
        }
        
        // Cycle through newEvents to add any that previously didn't exist.
        for event in newEvents {
            
            // If the event doesn't exist, add it.
            if events.firstIndex(where: {$0.startDate == event.startDate}) == nil {
                events.append(event)
                isExpanded.append(false)
            }
        }
    }// end of processNewEvents()
    
    
    
    func closeAll() {
        print("Close All")
        for i in 0..<isExpanded.count {
            isExpanded[i] = false
        }
    }
    
    func autoExpand() {
        if let index = events.firstIndex(where: {
            let wait = $0.startDate.timeIntervalSince1970 - Date().timeIntervalSince1970
            // View will expand fifteen minutes before start time; adjust this by changing the 15 to a different number of minutes.
            return 15 * 60 <= wait && wait <= 15 * 60 + 2}) {
            self.isExpanded[index] = true
        }
        if let index = events.firstIndex(where: {
            let wait = Date().timeIntervalSince1970 - $0.endDate.timeIntervalSince1970
            // View will un-expand at the end time. 
            return 0 <= wait && wait <= 2}) {
            self.isExpanded[index] = false
        }
        
    }
}
