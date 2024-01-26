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
    
    private(set) var userCalendars: [String: String] = [:] // List of calendars to connect to and their types; Persisted in UserDefaults
    @Published var appleCalendars: [AppleCalendar] = [] // List of all calendars in the Apple Calendar App
    @Published var selectedCalendars: Set<UUID> = Set([]) // Source of truth for which Apple Calendar App calendars are selected.
    
    
    init() {
        EventStore.shared.requestPermission()
        // Will ask the user for permission to access Calendar
        // Also instantiates a singleton EventStore for the whole app
        // This only happens once; the system only responds to it once anyway
        // If the response is no, the app will function, showing an empty calendar
        // The actual response is not needed here
    }
    
    func updateCalendars(completion: @escaping (CalendarError?) -> Void) {
        
        // Reset list of Apple Calendar App calendars to empty.
        self.appleCalendars = []
        
        guard EventStore.shared.permissionIsGiven else {
            completion(CalendarError.permissionDenied)
            return
        }
        
        // Grab a fresh list of calendars from the Apple Calendar App
        let getCalendars = EventStore.shared.store.calendars(for: .event)
        
        guard !getCalendars.isEmpty else {
            // No calendars are available to work with; this shouldn't happen. Calendar has default calendars. Yet somehow, it does happen... No, I think I figured it out and this shouldn't happen. I'll leave this here for now to see if it comes up again.
            completion(CalendarError.noAppleCalendars)
            return
        }
        
        guard (UserDefaults.standard.object(forKey: "calendars") != nil) else {
            completion(CalendarError.noUserDictionary)
            return
        }
        
        // Grab user default "calendars" - a dictionary matching calendars to display with their calendar types. If the dictionary isn't yet available, use an empty dictionary to indicate no calendars have been selected.
        userCalendars = UserDefaults.standard.dictionary(forKey: "calendars") as? [String : String] ?? ["" : ""]
        
        let titles = userCalendars.keys
        
        // Construct an AppleCalendar for each calendar in the user's Apple Calendar App. We are attatching isSelected and type to each EKCalendar. This will allow for easy editing of the user's calendars dictionary.
        
        for calendar in getCalendars {
            let isSelected = titles.contains(calendar.title)
            var type = "none"
            if let myType = userCalendars[calendar.title] {
                type = myType
            }
            let newCalendar = AppleCalendar(calendar: calendar, isSelected: isSelected, type: type)
            appleCalendars.append(newCalendar)
        }
        
        selectedCalendars = Set(self.appleCalendars.filter({$0.isSelected}).map({$0.id}))
        
        completion(nil)
        
    } // End function updateCalendars()
    
    
    // Call to persist user-selected calendar list to UserDefaults.
    func saveUserCalendars() {
        var myDictionary: [String: String] = [:]
        for calendar in appleCalendars {
            if calendar.isSelected {
                myDictionary[calendar.title] = calendar.type
            }
        }
        UserDefaults.standard.set(myDictionary, forKey: "calendars")
        userCalendars = myDictionary
        
        print("Calendars saved: ", myDictionary)
    }
}
