//
//  Enums.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 11/24/23.
//
//  Enums to make life easier.
//

import Foundation
import SwiftUI

// Defines the different calendar types used in the app.
enum CalendarType: String, CaseIterable, Identifiable {
    case meals = "meals"
    case medical = "medical"
    case daily = "daily"
    case special = "special"
    case banner = "banner"
    case none = "none"
    
    var id: String {self.rawValue}
    
    // This method returns an image to use for each different calendar type.
    func icon() -> Image {
        
        switch self {
        case .meals:
           return Image(systemName: "fork.knife.circle.fill")
        case .medical:
           return Image(systemName: "cross.circle.fill")
        case .daily:
           return Image(systemName: "calendar.circle.fill")
        case .special:
           return Image(systemName: "person.2.circle")
        default:
           return Image(systemName: "calendar.circle.fill")
        }
    }
    
    // This function returns each calendar type's priority. This number is used to determine which events views will be displayed more prominantly and which events to show when two or more are scheduled at the same time.
    func priority() -> Int {
        
        // higher value takes precidence over lower value
        switch self {
        case .meals:
            return 2
        case .medical:
            return 4
        case .daily:
            return 2
        case .special:
            return 3
        default:
            return 0
        }
    }
}


// Use this to return errors generated in communication with Apple's Calendar App.
// This is "in progress" - not sure yet whether or how the error titles/messages might be used.
enum CalendarError: Error {
    case noUserDictionary
    case noAppleCalendars
    case appleCalendarMissing
    case permissionDenied
    
    // Do we need these functions?
    // I don't know yet - will come back to this.
    func title() -> String {
        switch self {
        case .noUserDictionary:
            return "Please Connect With Your Apple Calendar App"
        case .noAppleCalendars:
            return "Please Set Up Your Apple Calendar"
        case .appleCalendarMissing:
            return "An Apple Calendar Is Missing"
        case .permissionDenied:
            return "Permission Required"
        }
    }
    
    func message() -> String {
        switch self {
        case .noUserDictionary:
            return "This app displays events from your Apple Calendar App. Please select which calendars you wish to display."
        case .noAppleCalendars:
            return ""
        case .appleCalendarMissing:
            return ""
        case .permissionDenied:
            return "Permission Required"
        }
    }
}

enum UserDefaultKey: String {
    case Calendars
    case Latitude
    case Longitude
    case MissingSolarDays
    case NewUser
    case UseDefaultNowIcon
    
}



