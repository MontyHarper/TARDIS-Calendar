//
//  StateBools.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 11/19/23.
//
//  Bools that determine state.
//  Perhaps this will become a state machine?
//

import EventKit
import Foundation

// For sharing names and values of state-related booleans.
// Names containing "Info" will pop up an alert with more info when a message is tapped.
// Names containing "Alert" will put an alert on screen (without a preceding message).


// TODO: should not be an observalbe object; should be local reasoning?

class StateBools: ObservableObject {
     
    static var shared = StateBools()
    var networkMonitor = NetworkMonitor()
        
    // Flag internet as down only if it's been down awhile. This way the user is not plagued with messages about trivial interruptions to the network. Change minSeconds to adjust the amount of time the connection needs to be lost before a notification pops up.
    var internetIsDown: Bool { // Displays a warning message on screen.
        let minSeconds: Double = 2*60*60 // two hours
        let down = networkMonitor.internetIsDown
        let downSince = UserDefaults.standard.object(forKey: UserDefaultKey.DateInternetWentDown.rawValue) as? Date ?? Date()
        let downAwhile = downSince.timeIntervalSince1970 >= minSeconds
        // Note: downAwhile will still be true once the connection has re-established, so we need both bools to be true here.
        return down && downAwhile
    }
    
    var marqueeNotShowing = true
    var missingSolarDays: Int {
        if let lastDate = UserDefaults.standard.object(forKey: UserDefaultKey.LastSolarDayDownloaded.rawValue) as? Date {
            let diff = Timeline.calendar.dateComponents([.day], from: lastDate, to: Date())
            return diff.day ?? 0
        } else {
            return 0
        }
    }
    var noCalendarsAvailable = false
    var noCalendarsSelected: Bool {
        if let calendars = UserDefaults.standard.object(forKey: UserDefaultKey.Calendars.rawValue) as? [String:String] {
            return calendars.isEmpty
        } else {
            return true
        }
    }
    var noPermissionForCalendar: Bool {
        !(EKEventStore.authorizationStatus(for: .event) == .authorized)
    }
    var authorizedForLocationAccess: Bool {
        UserDefaults.standard.bool(forKey: UserDefaultKey.AuthorizedForLocationAccess.rawValue)
    }
    var showMissingSolarDaysWarning: Bool { // If enough days are missing that the calendar will look wrong, show a warning.
        missingSolarDays >= 4
    }
    var showWarning: Bool { // Use to activate the AlertView, which will then show whichever warning is appropriate, with an attached alert for more information.
        noPermissionForCalendar || noCalendarsAvailable || noCalendarsSelected || internetIsDown || !authorizedForLocationAccess || showMissingSolarDaysWarning
    }
    var solarDaysAvailable = false // When false, background returns a solid color.
    var solarDaysUpdateLocked = false
    var solarDaysUpdateWaiting = false
    var solarDaysUpdateWaitingAll = false
    @Published var useDefaultNowIcon: Bool
    
    
    private init() {

        if UserDefaults.standard.bool(forKey: UserDefaultKey.UseDefaultNowIcon.rawValue) {
            useDefaultNowIcon = UserDefaults.standard.bool(forKey: UserDefaultKey.UseDefaultNowIcon.rawValue)
        } else {
            UserDefaults.standard.set(true, forKey: UserDefaultKey.UseDefaultNowIcon.rawValue)
            useDefaultNowIcon = true
        }
    }
}
