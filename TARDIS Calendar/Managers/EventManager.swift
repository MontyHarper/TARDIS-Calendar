//
//  EventManager.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 10/17/23.
//
//  Captures new events; provides an array of currently active events
//

import EventKit
import Foundation
import SwiftUI
import UIKit

class EventManager: CalendarManager {
    
    @Published var events = [Event]() // Upcoming events for the maximum number of days displayed.
    @Published var isExpanded = [Bool]() // For each event, should the view be rendered as expanded? This is the source of truth for expansion of event views.
    var bannerMaker = BannerMaker()
    var buttonMaker = ButtonMaker()
        
    // newEvents temporarily stores newly downloaded events whle processing.
    private var newEvents = [Event]()
    private let eventStore = EventStore.shared.store
    

    
    override init() {
        
        // This asks the user for permission to access Calendar.
        super.init()
        
        // These two both need an eventManager to function
        buttonMaker.eventManager = self
        bannerMaker.eventManager = self
        
        // This notification will update the calendars and events lists any time an event or calendar is changed in the user's Apple Calendar App.
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateEverything), name: .EKEventStoreChanged, object: eventStore)
        
        updateEverything()
        
    } // End init
    

    @objc func updateEverything() {
   
        guard EventStore.shared.permissionIsGiven else {
            return
        }
                
        updateCalendars() { [self] error in
            if let error = error {
                StateBools.shared.noCalendarsAvailable = (error == CalendarError.noAppleCalendars) || (error == CalendarError.noUserDictionary)
            } else {
                StateBools.shared.noCalendarsAvailable = false
                self.updateEvents()
                self.bannerMaker.updateBanners()
                self.buttonMaker.updateButtons()
            }
        }
    }
        
    
    func updateEvents() {
        
        print("updateEvents has been triggered")
        
        // Set up date parameters
        let start = Timeline.minDay
        let end = Timeline.maxDay
        
        // Search for events in selected calendars that are not banner type
        let calendarsToSearch = appleCalendars.filter({$0.isSelected && $0.type != "banner"}).map({$0.calendar})
        
        // Set up search predicate
        let findEKEvents = eventStore.predicateForEvents(withStart: start, end: end, calendars: calendarsToSearch)
        
        // Save which dates are shown in expanded view.
        let expandedDates = Set(isExpanded.indices.filter({isExpanded[$0]}).map({events[$0].startDate}))
                
        // Store the search results, converting EKEvents to Events.
        newEvents = eventStore.events(matching: findEKEvents).map({ekevent in
            Event(event: ekevent, type: userCalendars[ekevent.calendar.title] ?? "none")
        })
        
        // Filter the results to remove lower priority events scheduled at the same time as higher priority events...
        // TODO: - Test this!
        newEvents = newEvents.filter({event in
            let sameDate = self.newEvents.filter({$0.startDate == event.startDate})
            return event == sameDate.max()
        })
        
        // Update events
        events = newEvents
        
        // Restore dates that are expanded.
        isExpanded = events.indices.map({expandedDates.contains(events[$0].startDate)})
        
    } // End of updateEvents
    
    
    // Called when user taps the background; closes any expanded views.
    func closeAll() {
        isExpanded = isExpanded.map({_ in false})
    }
    
    
    // leaves only the requested event expanded
    func expandEvent(event: Event) {
        closeAll()
        if let index = events.indices.first(where: {events[$0] == event}) {
            isExpanded[index] = true
        }
    }
    
    func highlightNextEvent(timeline: Timeline) {
        let targetEvent = events.first(where: {$0.startDate > Date()})
        timeline.setTargetSpan(date: targetEvent?.startDate)
        if let targetEvent = targetEvent {
            expandEvent(event: targetEvent)
        }
        StateBools.shared.animateSpan = true
    }
    
}

