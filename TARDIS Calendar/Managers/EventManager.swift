//
//  EventManager.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 10/17/23.
//
//  Captures new events; provides an array of currently active events
//

import Combine
import EventKit
import Foundation
import SwiftUI
import UIKit

class EventManager: CalendarManager { // CalendarManager is an ObservableObject
    
    // Upcoming events for the maximum number of days displayed.
    @Published var events = [Event]() {
        didSet {
            print("events were updated: \(events.count)")
        }
    }
    @Published var isExpanded = [Bool]() // For each event, should the view be rendered as expanded? This is the source of truth for expansion of event views.
    @Published var bannerMaker = BannerMaker()
    @Published var buttonMaker = ButtonMaker()
    
        
    // newEvents temporarily stores newly downloaded events whle processing.
    private var newEvents = [Event]()
    private let eventStore = EventStore.shared.store
    private var internetConnection: AnyCancellable?
    private var updateWhenCurrentDayChanges: AnyCancellable?
    private var stateBools = StateBools.shared
    
    var warningTimer: Timer?
    
    var timeManager: TimeManager?

    override init() {
        
        super.init()
        
        // These two both need an eventManager to function
        buttonMaker.eventManager = self
        bannerMaker.eventManager = self
        
        // Will ask the user for permission to access Calendar
        // Also instantiates a singleton EventStore for the whole app
        // This only happens once; the system only responds to it once anyway
        // If the response is no, the app will function, showing an empty calendar
        // The actual response is not needed here
        // The update is in a trailing closure to prevent the eventManager from updating before permission is given
        EventStore.shared.requestPermission() {
            
            // This notification will update the calendars and events lists any time an event or calendar is changed in the user's Apple Calendar App.
            // Set up notifications AFTER permission is requested to avoid two updates triggered at once.
            NotificationCenter.default.addObserver(self, selector: #selector(self.updateEverything), name: .EKEventStoreChanged, object: self.eventStore)
            
            self.updateEverything()
        }
        
        // This notification will update everything if the internet connection is lost and returns.
        internetConnection = NetworkMonitor().objectWillChange.sink {_ in
            if !self.stateBools.internetIsDown {
                self.updateEverything()
            }
        }
        
        // This notification will update everything when the date changes.
        let dayTracker = DayTracker()
        updateWhenCurrentDayChanges = dayTracker.$today.sink { _ in
            self.updateEverything()
        }
        
    } // End init
    
    deinit {
        warningTimer?.invalidate()
    }
    
    
    // MARK: - Update Functions

    @objc func updateEverything() {
   
        print("Updating Everything in EventManager")
        
        guard EventStore.shared.permissionIsGiven else {
            return
        }
                
        updateCalendars() {error in
            
            if let error = error {
                print("Calendar Error: ", error as Any)
                switch error {
                case .permissionDenied, .noAppleCalendars, .noUserDictionary:
                    self.stateBools.noCalendarsAvailable = true
                    return
                default:
                    self.stateBools.noCalendarsAvailable = false
                }
            }
            
            // Keep these inside the updateCalendars closure so we know calendars are available before trying to update anything else.
            self.updateEvents() {
                
                // Keep this inside updateEvents closure because buttons depend on events.
                self.buttonMaker.updateButtons()
                self.setWarningTimer()
            }
            self.bannerMaker.updateBanners()
            
        }
    }
    
    func updateEvents(closure: @escaping ()->Void) {
        
        print("Updating Events")
        
        // Set up date parameters
        let start = Timeline.minDay
        let end = Timeline.maxDay
        
        // Search for events in selected calendars that are not banner type
        let calendarsToSearch = appleCalendars.filter({$0.isSelected && $0.type != "banner"}).map({$0.calendar})
        
        if calendarsToSearch.isEmpty {
            
            print("Updating events but there are no calendars to search.")
            // TODO: change to receive on main in the view
            DispatchQueue.main.async {
                self.events = [Event]()
                self.isExpanded = [Bool]()
                closure()
            }
            
        } else {
            
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
            
            // Update events on main thread
            
            DispatchQueue.main.async {
                
                self.events = self.newEvents
                
                // Restore dates that are expanded.
                self.isExpanded = self.events.indices.map({expandedDates.contains(self.events[$0].startDate)})
                
                closure()
            }
        }
        
    } // End of updateEvents
    
    
// MARK: - User Interactions
    
    // Called when user taps one of the navigation buttons.
    func buttonAction(type: String) {
        guard let timeManager = timeManager else {return}

        switch type {
            
        case "first":
            highlightNextEvent()
            
        case "all":
            closeAll()
            let targetDate: Date? = events.last(where: {$0.startDate > Date()})?.startDate
            timeManager.setTarget(targetDate ?? Timeline.maxDay)
            
        default:
            let targetEvent = events.first(where: {$0.type == type && $0.startDate > Date()})
            timeManager.setTarget(targetEvent?.startDate)
            expandEvent(targetEvent)
        }
    }
    
    // Called when user taps the background; closes any expanded views.
    func closeAll() {
        isExpanded = isExpanded.map({_ in false})
    }
    
    // leaves only the requested event expanded
    func expandEvent(_ event: Event?) {
        closeAll()
        if let index = events.indices.first(where: {events[$0] == event}) {
            isExpanded[index] = true
        }
    }
    
    func highlightNextEvent() {
        guard let timeManager = timeManager else {return}
        
        if let targetEvent = events.first(where: {$0.startDate > Date()}) {
            timeManager.setTarget(targetEvent.startDate)
            expandEvent(targetEvent)
        } else {
            timeManager.resetZoom()
        }
    }
    
    // MARK: - Utilities
    
    // Call to persist user-selected calendar list to UserDefaults.
    func saveUserCalendars() {
        var myDictionary: [String: String] = [:]
        for calendar in appleCalendars {
            if calendar.isSelected {
                myDictionary[calendar.title] = calendar.type
            }
        }
        UserDefaults.standard.set(myDictionary, forKey: UserDefaultKey.Calendars.rawValue)
        
        userCalendars = myDictionary
                       
        updateEverything()
    }
    
    
    func setWarningTimer() {
        warningTimer?.invalidate()
        
        // Highlight upcoming events this much ahead of time.
        // TODO: - make this a user preference
        let warningTime: Double = 30*60 // half an hour
        
        guard let targetEvent = events.first(where: {$0.startDate.timeIntervalSince1970 > Date().timeIntervalSince1970 + warningTime}) else {return}
            
        let targetTime = targetEvent.startDate.timeIntervalSince1970
        let secondsToWarning = (targetTime - Date().timeIntervalSince1970) - warningTime
                
        warningTimer = Timer.scheduledTimer(withTimeInterval: secondsToWarning, repeats: false) {_ in
            self.highlightNextEvent()
            self.setWarningTimer()
        }
    }
}

