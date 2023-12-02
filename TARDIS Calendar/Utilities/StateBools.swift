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
    var networkMonitor = NetworkMonitor()
    
    
    // TODO: - Below is a list of booleans I think I will need to deal with possible errors. Not all are used yet.
    // TODO: - Use an enum to track UserDefault keys to avoid typos.
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
   // @Published var internetIsDownInfo = false // Displays information if user taps warning message.
    
    var missingSolarDays = 0 { // Keeps count of how many times SolarDays cannot be downloaded; haven't used yet - not sure how or where to make an alert out of this.
        didSet {
            UserDefaults.standard.set(missingSolarDays, forKey: "missingSolarDays")
        }
    }
    var newLocationNoInternet = false // unused - do I want to remind the user an internet connection is needed to update solardays information for the new location?
   // @Published var newLocationNoInternetInfo = false
    var newUser = true // User is considered new the first time app is launched, but not subsequent times. Unused - do I need to do anything different for a brand new user?
    var noCalendarsSelected = true // working on it
    var noPermissionForCalendar = true {
        didSet {
            print("noPermissionForCalendar changed its mind. Now it's: ", noPermissionForCalendar)
        }
    }// I need to use this; if the user doesn't give permission, what should the app do?
  //  @Published var noPermissionForCalendarInfo = false
    var noPermissionForLocation = false // I need to use this; if the app can't get locatio info, what to show in background?
  //  @Published var noPermissionForLocationInfo = false
    var showLoadingBackground = false // Used to indicate the background is loading.
    var showSettings = false // Opens the settings page where user can select calendars to show.
    @Published var showSettingsAlert = false // Warns that a calendar must be selected.
    var showWarning: Bool { // Use to activate the AlertView, which will then show whichever warning is appropriate, with an attached alert for more information.
        noPermissionForCalendar || noCalendarsSelected || internetIsDown || noPermissionForLocation
    }
    
    private init() {
        missingSolarDays = UserDefaults.standard.integer(forKey: "missingSolarDays")
        if UserDefaults.standard.bool(forKey: "newUser") {
            newUser = false
        } else {
            UserDefaults.standard.set(true, forKey: "newUser")
        }
    }
}
