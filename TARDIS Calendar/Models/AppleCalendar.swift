//
//  AppleCalendar.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 1/23/24.
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
