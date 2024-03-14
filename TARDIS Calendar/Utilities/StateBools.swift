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
