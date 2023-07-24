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


// These are the colors to use to represent different times of the day.
extension Color {
    static var midnight = Color(hue: 0.668944, saturation: 1.0, brightness: 0.267304)
    static var sunrise = Color(hue: 0.105191, saturation: 0.763661, brightness: 1.0)
    static var morning = Color(hue: 0.544171, saturation: 0.579690, brightness: 1.0)
    static var noon = Color(hue: 0.544171, saturation: 0.223588, brightness: 1.0)
    static var evening = Color(hue: 0.610656, saturation: 0.546903, brightness: 0.819217)
    static var sunset = Color(hue: 0.824681, saturation: 0.420310, brightness: 0.964025)
}

extension Color {
    
    func parts () -> (hue: Double, saturation: Double, brightness: Double) {
        let cgColor = self.cgColor
        let uiColor = UIColor(cgColor: cgColor!)
        var (h,s,b,a) = (CGFloat.zero,CGFloat.zero,CGFloat.zero,CGFloat.zero)
        let _ = uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (hue: Double(h), saturation: Double(s), brightness: Double(b))
    }
}



// These will be user-set settings for the app. Not sure where to put them. For now there's only one.
struct Settings {
    static let maxTimeInDays = 14 // Number of days into the future the calendar can display.
}



// This initializes values needed to construct the calendar view.

struct Days {
    static var calendar = Calendar.current
    static var initialTrailingDate: Double {
        self.calendar.date(byAdding: .day, value: 1, to: Date())!.timeIntervalSince1970
    }
}


// These are the types of color stop.
// Will add a function to return the time for each stop as a percentage of the day.

enum ColorStop {
    case dawn
    case sunrise
    case morning
    case noon
    case evening
    case sunset
    case dusk
    case midnight
}


// Temporary solution to provide testing data.
// Day.stopsArray returns an array of "stops" representing a single generic day.
// A stop at this point is a regular tuple - will turn into actual stops later...
// Times are represented as percentages of the day.
// Once I figure out how to grab SunEvents, we need the function to return stops for a specific day.
// The progression is: Single day (this function) -> Multiple days -> actual stops that fit the screen

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



func screenStops(trailingDate: Double) -> [Gradient.Stop] {
    
    // Set up initial values
    let now = Date().timeIntervalSince1970
    let leadingDate = now - (trailingDate - now) / 4
    let calendar = Days.calendar
    // Array of stops to return
    var screenStops: [Gradient.Stop] = []
    
    // Begin with the first day
    var day: Date = calendar.startOfDay(for:Date(timeIntervalSince1970: leadingDate))
    
    // Iterate until the last day
    dayLoop: while day <= calendar.startOfDay(for:Date(timeIntervalSince1970: trailingDate)) {
        
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
            if stopTime < leadingDate {
                
                // Check if next stop is the first stop on screen
                if nextStopTime > leadingDate {
                    
                   // interpolate the first stop
                    let color1 = stop.0
                    let color2 = nextStop.0
                    let percent = (leadingDate - stopTime)/(nextStopTime - stopTime)
                    
                    let a = color1.parts().hue; let b = color1.parts().saturation; let c = color1.parts().brightness
                    let x = color2.parts().hue; let y = color2.parts().saturation; let z = color2.parts().brightness
                    
                    let newColor = Color(hue: a + (x-a)*percent, saturation: b + (y-b)*percent, brightness: c + (z-c)*percent)
                    
                    screenStops.append(.init(color:newColor, location:0.0))
                }
                
                // Check if stop is right of screen
            } else if stopTime > trailingDate {
                
                // interpolate final stop
                let color1 = stop.0
                let color2 = nextStop.0
                let percent = 1.0 - (stopTime - trailingDate)/(stopTime - trailingDate)
                
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
        return (0.8 * x + 0.2 * trailingDate - now) / (trailingDate - now)
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



    





