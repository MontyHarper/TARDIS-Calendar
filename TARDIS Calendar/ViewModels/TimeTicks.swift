//
//  TimeTicks.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 7/23/23.
//
//  View model for the labels marking time intervals along the top of the calendar.
//

import Foundation
import SwiftUI


// Each TimeTick may represent a particular hour or a particular day depending on the zoom level of the screen.
struct TimeTick {
        
    var date: Date
    var xLocation: Double // Horizontal location of the marker on the screen.
    var label: String
    
    // This method returns the array of TimeTicks that should appear onscreen, given the current timeline.
    static func array(timeline: Timeline) -> [TimeTick] {
        
        // Initialize an array of TimeTicks to return
        var array: [TimeTick] = []
        
        // Set up initial values
        let calendar = Timeline.calendar
        let leadingDate = timeline.leadingDate
        let trailingDate = timeline.trailingDate
        let now = Date(timeIntervalSince1970: timeline.now)
        
        // First tick is always "Now" - formatted as the current time.
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        array.append(TimeTick(date: now, xLocation: Timeline.nowLocation, label: formatter.string(from: now)))
        
        // Calculate the number of hours represented on screen.
        let onScreenHours = calendar.dateComponents([.hour], from: leadingDate, to: trailingDate).hour!
        
        // Show hours or days with the labels, depending on the number of hours on screen.
        switch onScreenHours {
            
        case 0...Int(24/(1-Timeline.nowLocation)):
            // labels will show hours
            
            // Begin at the current time plus one hour
            var tickDate = calendar.date(byAdding: .hour, value: 1, to: now)!
            
            // Iterate until the last hour
            while tickDate <= trailingDate {
                
                // Calculate location of label
                let xLocation = timeline.unitX(fromTime: tickDate.timeIntervalSince1970)
                
                // Calculate content of label
                let hours = calendar.dateComponents([.hour], from: now, to: tickDate).hour!
                
                let label = "\(hours.name()) Hour" + ((hours == 1) ? "" : "s")
                
                // Create the TimeTick
                let timeTick = TimeTick(date: tickDate, xLocation: xLocation, label: label)
                
                // Add this tick to the array
                array.append(timeTick)
                
                // Advance the hour
                tickDate = calendar.date(byAdding: .hour, value: 1, to: tickDate)!
            }
            
        default:
            // labels will show days
            
            // Begin with today if noon is more than six hours away; otherwise begin with tomorrow.
            let noon = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: now)?.timeIntervalSince1970
            var tickDate: Date = ((noon! - timeline.now) > 6 * 60 * 60) ? calendar.startOfDay(for: now) : calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: now)!)
            
            // Iterate until the last day
            while tickDate <= calendar.startOfDay(for: trailingDate) {
                
                // Place each label at noon of the day
                let noon = calendar.date(byAdding: .hour, value: 12, to: tickDate)!.timeIntervalSince1970
                let xLocation = timeline.unitX(fromTime: noon)
                
                // Calculate content of label
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE" // alt format: "EEE, MMM dd"
                let label = formatter.string(from: tickDate)
                
                // Create the TimeTick
                let timeTick = TimeTick(date: tickDate, xLocation: xLocation, label: label)
                
                // Add this tick to the array.
                array.append(timeTick)
                
                // Advance the day
                tickDate = calendar.date(byAdding: .day, value: 1, to: tickDate)!
            }
        }
        
        return array
        
    } // End of array function
}
