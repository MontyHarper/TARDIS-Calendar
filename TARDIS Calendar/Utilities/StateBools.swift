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

// Singleton for sharing names and values of state-related booleans.
// Names containing "Info" will pop up an alert with more info when a message is tapped.
// Names containing "Alert" will put an alert on screen (without a preceding message).

class StateBools: ObservableObject {
     
    static var shared = StateBools()
    var networkMonitor = NetworkMonitor()
    
    var animateSpan = false // When true, calendar view is auto-zooming back to default zoom.
    
    // Flag internet as down only if it's been down awhile. This way the user is not plagued with messages about trivial interruptions to the network. Change minSeconds to adjust the amount of time the connection needs to be lost before a notification pops up.
    var internetIsDown: Bool { // Displays a warning message on screen.
        let minSeconds: Double = 2*60*60 // two hours
        let down = networkMonitor.internetIsDown
        let downSince = UserDefaults.standard.object(forKey: "lastTimeInternetWentDown") as? Date ?? Date()
        let downAwhile = downSince.timeIntervalSince1970 >= minSeconds
        // Note: downAwhile will still be true once the connection has re-established, so we need both bools to be true here.
        return down && downAwhile
    }
    
    var locationChangeAwaitingUpdate = false
    var marqueeNotShowing = true
    var missingSolarDays = 0 { // Keeps count of how many times SolarDays cannot be downloaded;
        didSet {
            UserDefaults.standard.set(missingSolarDays, forKey: UserDefaultKey.MissingSolarDays.rawValue)
        }
    }
    @Published var newUser: Bool // User is considered new the first time app is launched, but not subsequent times. Use to open app to Settings with a welcome message.
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
    var authorizedForLocationAccess = false // Cannot be accessed directly (as far as I can figure out). Will be reset as soon as Events are updated.
    var showProgressView = false // Used to indicate the background is loading.
    var showMissingSolarDaysWarning: Bool { // If enough days are missing that the calendar will look wrong, show a warning.
        missingSolarDays >= 4
    }
    var showSettings: Bool // Opens the settings page where user can select calendars to show.
    @Published var showSettingsAlert = false // Warns that a calendar must be selected.
    var showWarning: Bool { // Use to activate the AlertView, which will then show whichever warning is appropriate, with an attached alert for more information.
        noPermissionForCalendar || noCalendarsAvailable || noCalendarsSelected || internetIsDown || !authorizedForLocationAccess || showMissingSolarDaysWarning
    }
    var solarDaysAvailable = false // When false, background returns a solid color.
    var solarDaysUpdateLocked = false
    @Published var useDefaultNowIcon: Bool
    
    
    private init() {
        missingSolarDays = UserDefaults.standard.integer(forKey: UserDefaultKey.MissingSolarDays.rawValue)
        if UserDefaults.standard.bool(forKey: UserDefaultKey.NewUser.rawValue) {
            newUser = false
            showSettings = false
        } else {
            UserDefaults.standard.set(true, forKey: UserDefaultKey.NewUser.rawValue)
            newUser = true
            showSettings = true
        }
        if UserDefaults.standard.bool(forKey: UserDefaultKey.UseDefaultNowIcon.rawValue) {
            useDefaultNowIcon = UserDefaults.standard.bool(forKey: UserDefaultKey.UseDefaultNowIcon.rawValue)
        } else {
            UserDefaults.standard.set(true, forKey: UserDefaultKey.UseDefaultNowIcon.rawValue)
            useDefaultNowIcon = true
        }
    }
}
