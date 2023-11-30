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
    
    
    var animateSpan = false // When true, calendar view is auto-zooming back to default zoom.
    
    // Does not flag internet as down unless it's been down awhile. This way the user is not plagued with trivial interruptions to the network. Change minSeconds to adjust the amount of time the connection needs to be lost before a notification pops up.
    var internetIsDown: Bool {
        let minSeconds: Double = 1.0
        let down = networkMonitor.internetIsDown
        let downSince = UserDefaults.standard.object(forKey: "lastTimeInternetWentDown") as? Date ?? Date()
        let downAwhile = downSince.timeIntervalSince1970 >= minSeconds
        // Note: downAwhile will still be true once the connection has re-established, so we need both bools to be true here.
        print("down = \(down) and downAwhile = \(downAwhile)")
        print("downSince = \(downSince)")
        return down && downAwhile
    }
    @Published var internetIsDownInfo = false
    
    var missingSolarDays = 0 {
        didSet {
            UserDefaults.standard.set(missingSolarDays, forKey: "missingSolarDays")
        }
    }
    var newLocationNoInternet = false
    @Published var newLocationNoInternetInfo = false
    var newUser = true // User is considered new the first time app is launched, but not subsequent times.
    var noPermissionForCalendar = false
    @Published var noPermissionForCalendarInfo = false
    var noPermissionForLocation = false
    @Published var noPermissionForLocationInfo = false
    var showSettings = false // Opens the settings page where user can select calendars to show.
    @Published var showSettingsAlert = false // Warns that a calendar must be selected.
    
    private init() {
        missingSolarDays = UserDefaults.standard.integer(forKey: "missingSolarDays")
        if UserDefaults.standard.bool(forKey: "newUser") {
            newUser = false
        } else {
            UserDefaults.standard.set(true, forKey: "newUser")
        }
    }
}
