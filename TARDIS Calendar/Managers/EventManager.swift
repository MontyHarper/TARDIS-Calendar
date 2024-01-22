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

// ContentView uses an instance of EventManager to access current events, calendars, and related info.
class EventManager: ObservableObject {
    
    var eventStore = EKEventStore()
    
    @Published var events = [Event]() // Upcoming events for the maximum number of days displayed.
    @Published var isExpanded = [Bool]() // For each event, should the view be rendered as expanded? This is the source of truth for expansion of event views.
    @Published var calendarSet = CalendarSet() // Tracks which of Apple's Calendar App calendars we're drawing events from.
    
    @Published var marquee: MarqueeController? // Messages that scroll
    
    @Published var buttons = [ButtonModel]()
    var buttonsExpire: Date = Timeline.maxDay
    
    // newEvents temporarily stores newly downloaded events so that events can be replaced with newEvents on the main thread.
    private var newEvents = [Event]()
    
    // vars needed to calculate banner text and intervals
    private var banners = [Event]()
    private var newBanners = [Event]()
    
    init() {
        // This notification will update the calendars and events lists any time an event or calendar is changed in the user's Apple Calendar App.
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCalendarsAndEvents), name: .EKEventStoreChanged, object: eventStore)
        
        updateCalendarsAndEvents()
        
    } // End init
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(eventStore)
    }
    
    @objc func updateCalendarsAndEvents() {
   
        guard itIsSafeToUpdate() == true else {
            return
        }
                
        calendarSet.updateCalendars(eventStore: eventStore) { error in
            if let error = error {
                StateBools.shared.noCalendarsAvailable = (error == CalendarError.noAppleCalendars) || (error == CalendarError.noUserDictionary)
            } else {
                StateBools.shared.noCalendarsAvailable = false
                self.updateEvents() // Called from within closure to ensure calendars are updated first.
            }
        }
    }
    
    func itIsSafeToUpdate() -> Bool {
        
        print("itIsSafeToUpdate called")
        
        // Returns true if we have permission
        // Otherwise we get permission
        
        if StateBools.shared.noPermissionForCalendar {
            // App will request access to the Apple Calendar. If the user refuses, the system will not show the request again.
            // This syntax is deprecated but I can't run the latest XCode on my old-ass computer.
            // TODO: - Buy a new iMac, install OS13, install xCode 15, and update this line.
            // Implementing solution suggested by Udacity reviewer...
            // My version won't build with the new request statement, so this will have to be commented out for my own use: lines 39-42, 45
            
            // Ask permission the new way if available
#if swift(>=5.9)
            if #available(iOS 17.0, *) {
                eventStore.requestFullAccessToEvents { _, _ in }
                
            } else {
                // Ask permission the old way if not
                eventStore.requestAccess(to: EKEntityType.event) { _, _ in }
            }
            // If permission is newly given, the notification above will fetch new data.
#else
            eventStore.requestAccess(to: EKEntityType.event) { _, _ in }
            
#endif
            // Even if permission is given, we return false because the change in permission will trigger an update anyway and we don't want two instances of the update function running at once.
            return false
            
        } else {
            return true
        }
    }
    
    
    func updateEvents() {
        
        print("updateEvents has been triggered")
        // Set up date parameters
        let start = Timeline.minDay
        let end = Timeline.maxDay
        
        // Set up search predicate
        let findEKEvents = eventStore.predicateForEvents(withStart: start, end: end, calendars: calendarSet.calendarsToSearch)
        
        // Save which dates are shown in expanded view.
        let expandedDates = Set(isExpanded.indices.filter({isExpanded[$0]}).map({events[$0].startDate}))
        
        print("user calendar: ", calendarSet.userCalendars)
        
        // Store the search results, converting EKEvents to Events.
        newEvents = eventStore.events(matching: findEKEvents).map({ekevent in
            Event(event: ekevent, type: calendarSet.userCalendars[ekevent.calendar.title] ?? "none")
        })
        
        // Split newEvents into newEvents and banners.
        newBanners = newEvents.filter {
            $0.type == "banner"
        }
        newEvents = newEvents.filter {
            $0.type != "banner"
        }
        
        // events has to be updated on the main queue.
        DispatchQueue.main.async {
            self.updateEventsCompletion(expandedDates)
        }
        
    } // End of updateEvents
    
    func updateEventsCompletion(_ expandedDates: Set<Date>) {
        
        marquee = nil

        if calendarSet.calendarsToSearch.count > 0 {
            
            events = newEvents
            banners = newBanners
            makeBanners()
            makeButtons()
            StateBools.shared.noCalendarsSelected = false
            
        } else {
            // No calendars have been selected. This means we had an empty search predicate, which returned events from all calendars. We don't want the user to see unrelated events from the Caregiver's personal calendars! So this will not be allowed; calendars must be selected before any events are shown.
            events = []
            banners = []
            buttons = []
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
    
    // Generate string from all banner messages
    func makeBanners() {
        
        // Replace banner text with new banners
        var bannerText = ""
        var bannerRefreshDate = Timeline.maxDay
        for banner in banners {
            if banner.startDate < Date() && banner.endDate > Date() {
                bannerText += banner.title + "  ★  "
            }
            if banner.startDate > Date() && banner.startDate < bannerRefreshDate {
                bannerRefreshDate = banner.startDate
            }
            if banner.endDate > Date() && banner.endDate < bannerRefreshDate {
                bannerRefreshDate = banner.endDate
            }
        } // End of loop
        
        print("new banner text: ", bannerText, "\nrefresh date: ", bannerRefreshDate.formatted())
        
        if bannerText != "" {
            marquee = MarqueeController(bannerText, refresh: bannerRefreshDate, fontSize: 24 )
        }
        
    }
    
    func makeButtons() {
    
        buttons = []
        buttonsExpire = Timeline.maxDay
        
        // Make a next event button
        var button = ButtonModel(eventManager: self, id: "first")
        buttons.append(button)
        
        // Make a button for each relevant calendar type
        for type in CalendarType.allCases {
            
            switch type {
            case .banner, .none:
                print("no button for type: ", type)
                
            default:
                if events.first(where: {$0.type == type.rawValue && $0.startDate > Date()}) != nil {
                    let button = ButtonModel(eventManager: self, id: type.rawValue)
                    buttons.append(button)
                }
                
                if let lastEvent = events.last(where: {$0.type == type.rawValue && $0.startDate > Date()}) {
                    buttonsExpire = (lastEvent.startDate < buttonsExpire) ? lastEvent.startDate : buttonsExpire
                }
            }
        } // End of calendar type buttons.
        
        // Make a button to span the whole timeline.
        button = ButtonModel(eventManager: self, id: "all")
        buttons.append(button)
    }
}

