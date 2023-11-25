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
                
        // App will request access to the Apple Calendar. This should only happen once if the user grants permission.
        eventStore.requestAccess(to: EKEntityType.event) { [self]granted, error in
            
            if granted {
                
                // Reset list of Apple Calendar App calendars to empty.
                self.appleCalendars = []
                
                // Grab a fresh list of calendars from the Apple Calendar App
                let getCalendars = eventStore.calendars(for: .event)
                
                guard getCalendars.count > 0 else {
                    // No calendars are available to work with.
                    completion(CalendarError.noAppleCalendars)
                    return
                }
                
                // Grab user default "calendars" - a dictionary matching calendars to display with their calendar types.
                if let myCalendars = UserDefaults.standard.dictionary(forKey: "calendars") {
                    self.userCalendars = myCalendars as! [String: String]
                    let titles = myCalendars.keys
                    
                    // Construct an AppleCalendar for each calendar in the user's Apple Calendar App. We are attatching isSelected and type to each EKCalendar. This will allow for easy editing of the user's calendars dictionary.
                    for calendar in getCalendars {
                        let isSelected = titles.contains(calendar.title)
                        var type = "none"
                        if let myType = myCalendars[calendar.title] as! String? {
                            type = myType
                        }
                        let newCalendar = AppleCalendar(calendar: calendar, isSelected: isSelected, type: type)
                        self.appleCalendars.append(newCalendar)
                    }
                    
                    selectedCalendars = Set(self.appleCalendars.filter({$0.isSelected}).map({$0.id}))

                } else {
                    // UserDefault "calendars" does not exist.
                    completion(CalendarError.noUserDictionary)
                }
                
            } else {
                // Permission to access Apple Calendar App is not granted.
                completion(CalendarError.permissionDenied)
            }
            
            completion(nil)
            
        } // End closure to eventStore.requestAccess
        
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
