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
    
    init(event: EKEvent) {
        self.event = event
    }
    
    var isSelected: Bool = false
    
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
    var calendar: String {
        event.calendar.title
    }
    var priority: Int {
        let calendars = UserDefaults.standard.dictionary(forKey: "calendars")
        return calendars?[calendar] as! Int
    }
    
    
    // Protocol conformance for comparable
    
    static func < (lhs: Event, rhs: Event) -> Bool {
        if lhs.startDate < rhs.startDate {
            return true
        } else {
            return lhs.priority > rhs.priority
        }
    }
    
    static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.startDate == rhs.startDate && lhs.priority == rhs.priority
    }
}




class EventManager: ObservableObject {
    
    @Published private(set) var selectedDates = Set<Date>() // set of event dates that are currently selected
    @Published var events = [Event]() // upcoming events for the maximum number of days allowed in the display
    @Published var eventViews = [EventView]() // views for upcoming events
    private var eventViewQueue = [EventView]() // recycles event views
    private let eventStore = EKEventStore()
    
    // Start with a freshly fetched list of events from the user's Apple Calendar app.
    init() {
        // TODO: - Hardcoding this for now; will need to allow user to set this up
        UserDefaults.standard.set(["Bena":1], forKey: "calendars")
        updateEvents()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateEvents), name: .EKEventStoreChanged, object: eventStore)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(eventStore)
    }
    
    // This method will update the array of events. Needs to be called once a day, or whenever the user adds or updates events in the calendar. Should update all events since we don't know what changes might have been made since last time.
    
    // TODO: - Get calendar name from user defaults
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
                    // TODO: - Handle a "no calendars found" event gracefully
                }
                
                // Set up date parameters
                let start = Timeline.minDay
                let end = Timeline.maxDay
                
                // Set up search prediate
                let findEKEvents = self.eventStore.predicateForEvents(withStart: start, end: end, calendars: calendarsToSearch)
                
                // Store the search results
                self.events = self.eventStore.events(matching: findEKEvents).map({ekevent in
                    Event(event: ekevent)
                })
                
                // Filter the search results to remove lower priority events scheduled at the same time as higher priority events...
                self.events = self.events.filter({event in
                    let sameDate = self.events.filter({$0.startDate == event.startDate})
                    return event == sameDate.max()
                })
                
                DispatchQueue.main.async {self.recycleEventViews()}
                
            } else {
                print(error as Any)
                print("Permission not granted to fetch events.")
            }
        }
    }
    
    func recycleEventViews() {
        print("Recycle event views is called. There are \(eventViews.count) views and \(eventViewQueue.count) views in the queue.")
                
        // Cycle through event views from last to first to remove un-needed views
        if eventViews.count > 0 {
            let last = eventViews.count - 1
            for index in stride(from: last, through: 0, by: -1) {
                let startDate = eventViews[index].event.startDate
                if let eventIndex = events.firstIndex(where: {$0.startDate == startDate}) {
                    // This view corresponds to an event. Update the view's event.
                    eventViews[index].event = events[eventIndex]
                }
                else {
                    // This view no longer corresponds to an event so remove it to the queue.
                    selectedDates.remove(eventViews[index].event.startDate)
                    eventViewQueue.append(eventViews.remove(at:index))
                }
            }
        }
        
        print("making views for \(events.count) events:")
        // Cycle through events to add views for new events
        for event in events {
            if let index = eventViews.firstIndex(where: {$0.event == event}) {
                // This event has a view; update as needed.
                eventViews[index].event.event.refresh()
            } else {
                // This event doesn't have a view yet, so recycle one or construct a new one.
                if eventViewQueue.count > 0 {
                    eventViews.append(eventViewQueue.popLast()!)
                    let index = eventViews.count - 1
                    eventViews[index].event = event
                    eventViews[index].event.isSelected = false
                    print("recycling a view")
                } else {
                    eventViews.append(EventView(event: event))
                    print("new view")
                }
            }
        }
    } // end of recycleEventViews()
    
    func toggleView(_ view: EventView) {
        if selectedDates.contains(view.event.startDate) {
            selectedDates.remove(view.event.startDate)
        } else {
            selectedDates.insert(view.event.startDate)
        }
    }
    
    func closeAll() {
        print("Close All")
        selectedDates.removeAll()
    }
}
