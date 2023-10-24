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


class EventManager: ObservableObject {
    
    private var events = [EKEvent]() // upcoming events for the maximum number of days allowed in the display
    @Published var eventViews = [EventView]() // views for upcoming events
    private var eventViewQueue = [EventView]() // recycles event views
    private let eventStore = EKEventStore()
    
    // Start with a freshly fetched list of events from the user's Apple Calendar app.
    init() {
        updateEvents()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateEvents), name: .EKEventStoreChanged, object: eventStore)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(eventStore)
    }
    
    // This method will update the array of events. Needs to be called once a day, or whenever the user adds or updates events in the calendar. Should update all events since we don't know what changes might have been made since last time.
    
    // TODO: - Get calendar name from user defaults
    // TODO: - Trigger this function once per day
    // TODO: - Trigger this function whenever calendar events change
    @objc func updateEvents() {
        print("update events is called")
        eventStore.requestAccess(to: EKEntityType.event) {granted, error in
            if granted {
                let calendars = self.eventStore.calendars(for: .event)
                let myCalendar = calendars.first(where: { $0.title == "Bena" })!
                let start = Date()
                let end = Timeline.calendar.date(byAdding: .day, value: Timeline.maxFutureDays, to: start)!
                let timeSpan = self.eventStore.predicateForEvents(withStart: start, end: end, calendars: [myCalendar])
                self.events = self.eventStore.events(matching: timeSpan)
                DispatchQueue.main.async {self.recycleEventViews()}
            } else {
                print(error as Any)
                print("Permission not granted to fetch events.")
            }
        }
    }
    
    func recycleEventViews() {
        print("Recycle event views is called. There are \(eventViews.count) views and \(eventViewQueue.count) views in the queue.")
        
        // Cycle through fetched events to remove any duplicate times.
        // TODO: - sort using calendar tags to determine priority if two events start together.
        events.sort {$0.startDate < $1.startDate}
        var index = 0
        while index + 1 < events.count {
            if events[index].startDate == events[index + 1].startDate {
                events.remove(at: index)
            } else {
                index += 1
            }
        }
                
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
                    eventViewQueue.append(eventViews.remove(at:index))
                }
            }
        }
        
        print("making views for \(events.count) events:")
        // Cycle through events to add views for new events
        for event in events {
            if let index = eventViews.firstIndex(where: {$0.event == event}) {
                // This event has a view; update as needed.
                eventViews[index].event.refresh()
            } else {
                // This event doesn't have a view yet, so recycle one or construct a new one.
                if eventViewQueue.count > 0 {
                    eventViews.append(eventViewQueue.popLast()!)
                    eventViews[eventViews.count - 1].event = event
                    print("recycling a view")
                } else {
                    eventViews.append(EventView(event: event))
                    print("new view")
                }
            }
        }
    } // end of recycleEventViews()
    
    func closeAll() {
        print("Close All")
        for view in eventViews {
            view.isSelected = false
        }
    }
}
