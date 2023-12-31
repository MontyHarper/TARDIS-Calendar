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
        
        // First tick is always "Now"
        array.append(TimeTick(date: now, xLocation: Timeline.nowLocation, label: "NOW"))
        // Second tick at half an hour
        let halfAnHour = calendar.date(byAdding: .minute, value: 30, to: now)!
        array.append(TimeTick(date: halfAnHour, xLocation: timeline.unitX(fromTime: halfAnHour.timeIntervalSince1970), label: "Half an Hour"))
        
        // Calculate the number of hours represented on screen.
        let onScreenHours = calendar.dateComponents([.hour], from: leadingDate, to: trailingDate).hour!
        
        // Show hours or days with the labels, depending on the number of hours on screen.
        switch onScreenHours {
            
        case 0...Int(40/(1-Timeline.nowLocation)):
            // labels will show hours
            
            // Begin at the current time plus one hour
            var tickDate = calendar.date(byAdding: .hour, value: 1, to: now)!
            
            // Iterate until the last hour
            while tickDate <= trailingDate {
                
                // Calculate location of label
                let xLocation = timeline.unitX(fromTime: tickDate.timeIntervalSince1970)
                
                // Calculate content of label
                let components = calendar.dateComponents([.hour, .day], from: now, to: tickDate)
                let hoursToTick = components.hour! + components.day! * 24
                let hourOfTick = calendar.dateComponents([.hour], from: tickDate).hour!
                let daysToTick = calendar.dateComponents([.day], from: calendar.startOfDay(for: now), to: calendar.startOfDay(for: tickDate)).day!
                
                var label = ""
                
                if hoursToTick <= 8 {
                    label = "\(hoursToTick.name()) Hour" + ((hoursToTick == 1) ? "" : "s")
                } else if daysToTick == 0 && hoursToTick % 3 == 0 {
                    switch hourOfTick {
                    case 0...4: label = "Tonight"
                    case 5...11: label = "This Morning"
                    case 12...16: label = "This Afternoon"
                    case 17...20: label = "This Evening"
                    case 21...24: label = "Tonight"
                    default: label = "Today"
                    }
                } else if daysToTick == 1 && hoursToTick % 3 == 0 {
                    switch hourOfTick {
                    case 0...4: label = "Tomorrow"
                    case 5...11: label = "Tomorrow Morning"
                    case 12...16: label = "Tomorrow Afternoon"
                    case 17...20: label = "Tomorrow Evening"
                    case 21...24: label = "Tomorrow Night"
                    default: label = "Tomorrow"
                    }
                } else if daysToTick > 1 {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "EEEE"
                    label = formatter.string(from: tickDate)
                }
                
                // Create the TimeTick
                
                let timeTick = TimeTick(date: tickDate, xLocation: xLocation, label: label)
                
                
                // Add this tick to the array
                if label != "" {
                    array.append(timeTick)
                }
                
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
