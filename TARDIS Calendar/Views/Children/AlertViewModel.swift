//
//  AlertViewModel.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 3/13/24.
//

import SwiftUI
import EventKit

class AlertViewModel {
    
    var someWarningIsShowing: Bool {
        noPermissionForCalendar || noCalendarsAvailable || noCalendarsSelected || internetIsDown || notAuthorizedForLocationAccess || missingSolarDaysAlertIsShowing
    }
    
    var noPermissionForCalendar: Bool {
        !(EKEventStore.authorizationStatus(for: .event) == .authorized)
    }
    
    var noCalendarsAvailable: Bool = false // Figure this one out
    
    var noCalendarsSelected: Bool {
        if let calendars = UserDefaults.standard.object(forKey: UserDefaultKey.Calendars.rawValue) as? [String:String] {
            return calendars.isEmpty
        } else {
            return true
        }
    }
    
    // Flag internet as down only if it's been down awhile. This way the user is not plagued with messages about trivial interruptions to the network. Change minSeconds to adjust the amount of time the connection needs to be lost before a notification pops up.
    var internetIsDown: Bool {
        // To avoid frequent or trivial warnings, inject a waiting period before showing a message that the internet is down.
        let minSeconds: Double = 2 //*60*60 // Waiting period set for two hours
        let down = NetworkMonitor.internetIsDown
        let downSince = UserDefaults.standard.object(forKey: UserDefaultKey.DateInternetWentDown.rawValue) as? Date ?? Date()
        let downAwhile = (Date.now.timeIntervalSince1970 - downSince.timeIntervalSince1970) >= minSeconds
        // Note: downAwhile will still be true once the connection has re-established, so we need both bools to be true here.
        return down && downAwhile
    }
    
    let dateInternetWentDown = UserDefaults.standard.object(forKey: UserDefaultKey.DateInternetWentDown.rawValue) as? Date ?? Date()
    
    var notAuthorizedForLocationAccess: Bool {
        !UserDefaults.standard.bool(forKey: UserDefaultKey.AuthorizedForLocationAccess.rawValue)
    }
    
    var missingSolarDays: Int {
        if let lastDate = UserDefaults.standard.object(forKey: UserDefaultKey.LastSolarDayDownloaded.rawValue) as? Date {
            let diff = Timeline.calendar.dateComponents([.day], from: lastDate, to: Date())
            return diff.day ?? 0
        } else {
            return 0
        }
    }
    
    var missingSolarDaysAlertIsShowing: Bool {
        missingSolarDays >= 4
    }
    
}
