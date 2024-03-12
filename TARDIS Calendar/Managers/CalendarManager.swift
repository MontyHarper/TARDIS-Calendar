//
//  CalendarManager.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 11/20/23.
//
//  Provides a list of calendars to search for events, based on user settings.
//

import EventKit
import Foundation
import SwiftUI

class CalendarManager: ObservableObject {
    
    // List of calendars to connect to and their types; Persisted in UserDefaults
    @Published var userCalendars: [String: String] = UserDefaults.standard.dictionary(forKey: UserDefaultKey.Calendars.rawValue) as? [String : String] ?? ["" : ""] {
        
        didSet {
            UserDefaults.standard.set(userCalendars, forKey: UserDefaultKey.Calendars.rawValue)
        }
    }
    
    // List of all calendars in the Apple Calendar App
    @Published var appleCalendars = [AppleCalendar]()
    
    init() {
        updateCalendars(completion: {error in})
    }
    
    func updateCalendars(completion: @escaping (CalendarError?) -> Void) {
                
        guard EventStore.shared.permissionIsGiven else {
            completion(CalendarError.permissionDenied)
            return
        }
        
        // Grab a fresh list of calendars from the Apple Calendar App
        let getCalendars = EventStore.shared.store.calendars(for: .event)
        
        guard !getCalendars.isEmpty else {
            // No calendars are available to work with; this shouldn't happen. Calendar has default calendars.
            completion(CalendarError.noAppleCalendars)
            return
        }
        
        let titles = userCalendars.keys
        
        // Construct an AppleCalendar for each calendar in the user's Apple Calendar App. We are attatching isSelected and type to each EKCalendar. This will allow for easy editing of the user's calendars dictionary.
        var newCalendars = [AppleCalendar]()
        for calendar in getCalendars {
            let isSelected = titles.contains(calendar.title)
            var type = "none"
            if let myType = userCalendars[calendar.title] {
                type = myType
            }
            let newCalendar = AppleCalendar(calendar: calendar, isSelected: isSelected, type: type)
            newCalendars.append(newCalendar)
        }
        
        // Reconstruct userCalendars; this is needed in case new calendars have been selected or previously selected calendars have been deleted or renamed.
        var newUserCalendars: [String: String] = [:]
        for calendar in newCalendars {
            if calendar.isSelected {
                newUserCalendars[calendar.title] = calendar.type
            }
        }
        
        // Update on the main thread
        
        DispatchQueue.main.async {
            self.appleCalendars = newCalendars
            self.userCalendars = newUserCalendars
            completion(nil)
        }

    } // End function updateCalendars()
    
}
