//
//  CalendarSet.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 11/20/23.
//
//  Provides a list of calendars to search for events, based on user settings.
//

import EventKit
import Foundation
import SwiftUI


// This is a wrapper for EventKit's raw EKCalendar Type.
// - Conforms calendars to identifiable and hashable
// - Gives each calendar an id and a type
struct AppleCalendar: Identifiable, Hashable {
    
    var calendar: EKCalendar
    var isSelected: Bool // Source of truth
    var type: String
    var id = UUID()
    
    var title: String {
        calendar.title
    }
    var color: Color {
        Color(calendar.cgColor)
    }
}


class CalendarSet: ObservableObject {
    
    private(set) var userCalendars: [String: String] = [:] // List of calendars to connect to and their types; Persisted in UserDefaults
    @Published var appleCalendars: [AppleCalendar] = [] // List of all calendars in the Apple Calendar App
    @Published var selectedCalendars: Set<UUID> = Set([]) // Source of truth for which Apple Calendar App calendars are selected.
    
    var calendarsToSearch: [EKCalendar] { // Apple Calendars that are selected.
        appleCalendars.filter({$0.isSelected}).map({$0.calendar})
    }
    
    func updateCalendars(eventStore: EKEventStore, completion: @escaping (CalendarError?) -> Void) {
        
        print("I'm clearing out appleCalendars.")
        // Reset list of Apple Calendar App calendars to empty.
        self.appleCalendars = []
        
        // Grab a fresh list of calendars from the Apple Calendar App
        let getCalendars = eventStore.calendars(for: .event)
        
        guard getCalendars.count > 0 else {
            // No calendars are available to work with; this shouldn't happen. Calendar has default calendars. Yet somehow, it does happen... No, I think I figured it out and this shouldn't happen. I'll leave this here for now to see if it comes up again.
            completion(CalendarError.noAppleCalendars)
            return
        }
        
        // Grab user default "calendars" - a dictionary matching calendars to display with their calendar types. If the dictionary isn't yet available, use an empty dictionary to indicate no calendars have been selected.
        let myCalendars = UserDefaults.standard.dictionary(forKey: "calendars") as? [String : String] ?? ["" : ""]
        
        self.userCalendars = myCalendars
        let titles = myCalendars.keys
        
        // Construct an AppleCalendar for each calendar in the user's Apple Calendar App. We are attatching isSelected and type to each EKCalendar. This will allow for easy editing of the user's calendars dictionary.
        
        for calendar in getCalendars {
            let isSelected = titles.contains(calendar.title)
            var type = "none"
            if let myType = myCalendars[calendar.title] {
                type = myType
            }
            let newCalendar = AppleCalendar(calendar: calendar, isSelected: isSelected, type: type)
            self.appleCalendars.append(newCalendar)
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
    }
}
