//
//  CalendarSet.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 11/20/23.
//

import EventKit
import Foundation
import SwiftUI

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
    
    private(set) var userCalendars: [String: String] = [:]
    @Published var appleCalendars: [AppleCalendar] = []
    @Published var selectedCalendars: Set<UUID> = Set([]) // Derived from isSelected property
    
    var calendarsToSearch: [EKCalendar] {
        appleCalendars.filter({$0.isSelected}).map({$0.calendar})
    }
    
    // TODO: - update this to throw errors. Then deal with the errors.
    
    func updateCalendars(eventStore: EKEventStore, completion: @escaping (CalendarError?) -> Void) {
                
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
                    
                    // Construct an AppleCalendar for each calendar in the user's Appke Calendar App. We are attatching isSelected and type to each EKCalendar. This will allow for easy editing of the user's calendars dictionary.
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
