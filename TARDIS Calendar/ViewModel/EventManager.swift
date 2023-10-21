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


class EventManager {
    
    // This array holds upcoming events for the maximum span of time allowed to show on the calendar.
    public var events = [EKEvent]()
    
    
    // Initializes the array with events fetched from the user's Apple Calendar app.
    init() {

        updateEvents()
    }
    
    // This function should return an array of event views for display in the main calendar view.
    
    // TODO: - Refactor so the array function takes both EndDate and Now as parameters instead of span.
    func eventViewArray(timeline: Timeline) -> [EventView] {
        
        var viewsArray = [EventView]()
        
        
        for event in events {
            
            if (timeline.leadingDate ... timeline.trailingDate).contains(event.startDate) {
                
                var view = EventView(startDate: event.startDate, endDate: event.endDate, title: event.title)
                view.xLocation = timeline.unitX(fromTime: event.startDate.timeIntervalSince1970)
                
                viewsArray.append(view)
            }
        }
        return viewsArray
    }
    
    // This method will update the array of events. Needs to be called once a day, or whenever the user adds or updates events in the calendar. Should update all events since we don't know what changes might have been made since last time.
    
    // TODO: - Get calendar name from user defaults
    // TODO: - Trigger this function once per day
    // TODO: - Trigger this function whenever calendar events change
    func updateEvents() {
        var fetchedEvents: [EKEvent] = []
        let store = EKEventStore()
        store.requestAccess(to: EKEntityType.event) {granted, error in
            if granted {
                let calendars = store.calendars(for: .event)
                let myCalendar = calendars.first(where: { $0.title == "Bena" })!
                let time = Time(span: Time.maxSpan)
                let nextTwoWeeks = store.predicateForEvents(withStart: time.leadingDate, end: time.trailingDate, calendars: [myCalendar])
                fetchedEvents = store.events(matching: nextTwoWeeks)
            } else {
                print(error as Any)
            }
        }
        events = fetchedEvents
        
    }

}
