//
//  StateBools.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 11/19/23.
//
//  Bools that determine state.
//  Perhaps this will become a state machine?
//

import Foundation

// Singleton for sharing names and values of state-related booleans.
// Names containing "Info" will pop up an alert with more info when a message is tapped.
// Names containing "Alert" will put an alert on screen (without a preceding message).

class StateBools: ObservableObject {
     
    static var shared = StateBools()
    
    var animateSpan = false // When true, calendar view is auto-zooming back to default zoom.
    var daysWithNoInternet = 0 {
        didSet {
            UserDefaults.standard.set(self, forKey: "daysWithNoInternet")
        }
    } // Used to determine if internet is persistently down.
    var internetDown = false
    @Published var internetDownInfo = false
    @Published var internetDownAlert = false
    var internetPersistentlyDown = false // Will not message user unless it's really a problem.
    @Published var internetPersistentlyDownInfo = false
    var newLocationNoInternet = false
    @Published var newLocationNoInternetInfo = false
    var newUser = true // User is new first time app is launched, but not subsequent times.
    var noPermissionForCalendar = false
    @Published var noPermissionForCalendarInfo = false
    var noPermissionForLocation = false
    @Published var noPermissionForLocationInfo = false
    var showSettings = false // Opens the settings page where user can select calendars to show.
    @Published var showSettingsAlert = false // Warns that a calendar must be selected.
    
    private init() {
        daysWithNoInternet = UserDefaults.standard.integer(forKey: "daysWithNoInternet")
        internetPersistentlyDown = (daysWithNoInternet >= 2)
        if UserDefaults.standard.bool(forKey: "newUser") {
            newUser = false
        } else {
            UserDefaults.standard.set(true, forKey: "newUser")
        }
    }
}
