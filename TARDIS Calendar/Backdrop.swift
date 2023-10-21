//
//  Backdrop.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 7/18/23.
//
//  Structs and Functions needed to create the color gradient backdrop for the calendar view.
//

import Foundation
import SwiftUI


func sunriseSunset(date: Date, lat: Double, lng: Double, completion:(SolarDay)->()) {
    
    
}


func dayStops(_ day:Date) -> [(Color,Double)] {
    
    // var sunrise: Date
    // var sunset: Date
    
    var sunrisePercent: Double {
        return 0.2
    }
    
    var sunsetPercent: Double {
        return 0.8
    }
    
    var noonPercent1: Double {
        return (sunsetPercent + sunrisePercent) / 2 - 0.05
    }
    
    var noonPercent2: Double {
        return (sunsetPercent + sunrisePercent) / 2 + 0.05
    }
    
    var morningPercent: Double {
        return sunrisePercent + 0.01
    }
    
    var eveningPercent: Double {
        return sunsetPercent - 0.01
    }
    
    var midnightPercent1: Double {
        return sunrisePercent - 0.02
    }
    
    var midnightPercent2: Double {
        return sunsetPercent + 0.02
    }
    
    var stopsArray: [(Color,Double)] {
        
        return [
            (color: .midnight, location: midnightPercent1),
            (color: .sunrise, location: sunrisePercent),
            (color: .morning, location: morningPercent),
            (color: .noon, location: noonPercent1),
            (color: .noon, location: noonPercent2),
            (color: .evening, location: eveningPercent),
            (color: .sunset, location: sunsetPercent),
            (color: .midnight, location: midnightPercent2)
        ]
    }
    
    return stopsArray
}
    

// Creates an array of gradient stops (tuples) for all the days listed in Days.array.
// Times are expressed as percentages of the first day; second day times are 100+ %, etc.
func calendarStops() -> [(Color,Double)] {
    return[]
}



func screenStops(span: TimeInterval, now: TimeInterval) -> [Gradient.Stop] {
    
    // Set up initial values
    let time = Time(span: span)
    let leadingTime = time.leadingTime
    let trailingTime = time.trailingTime
    let calendar = Time.calendar
    // Array of stops to return
    var screenStops: [Gradient.Stop] = []
    
    // Begin with the first day
    var day: Date = calendar.startOfDay(for:Date(timeIntervalSince1970: leadingTime))
    
    // Iterate until the last day
    dayLoop: while day <= calendar.startOfDay(for:Date(timeIntervalSince1970: trailingTime)) {
        
        let stops = dayStops(day) // Get a list of this day's stops: will incorporate sunrise and sunset
        let nextDay = calendar.date(byAdding: .day, value: 1, to: day)!
        let lengthOfDay = nextDay.timeIntervalSince1970 - day.timeIntervalSince1970 // using the calendar to incorporate leap days and such
        // can I use calendar to get lengthOfDay without referencing two days?? - needed below
        
        // iterate over stops
        for i in 0 ..< stops.count {
            
            // Convert stop into date in seconds
            let stop = stops[i]
            let stopTime = day.timeIntervalSince1970 + lengthOfDay * stop.1
            var nextStop: (Color, Double)
            // Find next stop
            if i + 1 == stops.count {
                nextStop = dayStops(nextDay)[0]
            } else {
                nextStop = stops[i + 1]
            }
            let nextStopTime = day.timeIntervalSince1970 + lengthOfDay * nextStop.1
            
            // Check if stop is left of the screen
            if stopTime < leadingTime {
                
                // Check if next stop is the first stop on screen
                if nextStopTime > leadingTime {
                    
                   // interpolate the first stop
                    let color1 = stop.0
                    let color2 = nextStop.0
                    let percent = (leadingTime - stopTime)/(nextStopTime - stopTime)
                    
                    let a = color1.parts().hue; let b = color1.parts().saturation; let c = color1.parts().brightness
                    let x = color2.parts().hue; let y = color2.parts().saturation; let z = color2.parts().brightness
                    
                    let newColor = Color(hue: a + (x-a)*percent, saturation: b + (y-b)*percent, brightness: c + (z-c)*percent)
                    
                    screenStops.append(.init(color:newColor, location:0.0))
                }
                
                // Check if stop is right of screen
            } else if stopTime > trailingTime {
                
                // interpolate final stop
                let color1 = stop.0
                let color2 = nextStop.0
                let percent = 1.0 - (stopTime - trailingTime)/(stopTime - trailingTime)
                
                let a = color1.parts().hue; let b = color1.parts().saturation; let c = color1.parts().brightness
                let x = color2.parts().hue; let y = color2.parts().saturation; let z = color2.parts().brightness
                
                let newColor = Color(hue: a + (x-a)*percent, saturation: b + (y-b)*percent, brightness: c + (z-c)*percent)
                
                screenStops.append(.init(color:newColor, location:1.0))
                
                break dayLoop // exit loop
                
            } else {
                // add stop to the array
                screenStops.append(.init(color:stops[i].0, location:dateToStop(stopTime)))
            }
            
        }
        // end of stops loop
    
        day = nextDay
    
    } // end of days loop
    
    return screenStops
    
    // This function converts an actual date in seconds into a location on the screen.
    func dateToStop(_ x:Double) -> Double {
        
        // linear transformation changing a given date x into a percent length of the screen.
        return ((1.0 - Settings.shared.nowLocation) * x + Settings.shared.nowLocation * trailingTime - now) / (trailingTime - now)
    }
    
} // end of screenStops function


    





// Returns a Date/time object from a given string, using the given format.
// Input should include the full month name.
// Not sure if I will end up needing this.

func DateOf(_ dateString:String) -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM dd, yyyy HH:mm p"
    let date = formatter.date(from: dateString) ?? Date()
    return date
}



    





