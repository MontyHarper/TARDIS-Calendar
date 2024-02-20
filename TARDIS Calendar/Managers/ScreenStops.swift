//
//  ScreenStops.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 2/17/24.
//
//  Generates the gradient stops needed to render the background.
//

import SwiftUI

// This struct just basically houses one function.

struct ScreenStops {
    
    // MARK: - Generate Stops
    // TODO: Refactor?
    // Could you generate one array of screenstops that encompasses all the solar days, create a gradient out of that in your UI, and size / offset that gradient in response to the timeline so the part you want appears onscreen?

    static func generate(for solarDays: [SolarDay], timeline: Timeline) -> [Gradient.Stop] {
        
        guard !solarDays.isEmpty else {
            print("Trying to generate screen stops but solarDays is empty: ", Date())
            return [Gradient.Stop(color: Color.noon, location: 0.0)]
        }
        
        print("Generating screen stops: ", Date())
        var stops = [Gradient.Stop]()
        let leadingDate = timeline.leadingDate
        let leadingTime = timeline.leadingTime
        let trailingDate = timeline.trailingDate
        let trailingTime = timeline.trailingTime
        let calendar = timeline.calendar
        
        // Begin with the leadingDate (first date visible on screen)
        var day: Date = calendar.startOfDay(for:leadingDate)
        
        // Iterate through the trailingDate (last date visible on screen)
        let lastDay: Date = calendar.startOfDay(for:trailingDate)
        
        dayLoop: while day <= lastDay {
            
            // Find this day's solar events. If they dont exist, exit the loop
            guard let thisSolarDay = solarDays.first(where: {$0.dateDate == day}) else {
                break dayLoop
            }
            let solarEvents = thisSolarDay.colorsAndTimes
            let nextDay = calendar.date(byAdding: .day, value: 1, to: day)!
            
            // Iterate over stops in the current day.
            stopLoop: for i in 0 ..< solarEvents.count {
                
                let event = solarEvents[i]
                
                // Find the event for the next stop; go to the next day if needed
                var nextEvent: (Color, Double)
                if i + 1 == solarEvents.count {
                    if let index = solarDays.firstIndex(where: {$0.dateDate == nextDay}) {
                        nextEvent = solarDays[index].colorsAndTimes[0]
                    } else {
                        // If we've run out of events (shouldn't happen), just use the current event again.
                        nextEvent = event
                    }
                } else { // Grab the next event in the current solar day.
                    nextEvent = solarEvents[i + 1]
                }
                
                // Now we have times in seconds for the current event and the next event.
                let stopTime = event.1
                let nextStopTime = nextEvent.1
                
                // We need to create a screenStop for this event, if the event is "onscreen."
                // If we are at either edge of the screen, the color for the stop needs to be interpolated.
                
                // First, check if the entire screen lies between this event and the next event. If so, interpolate both endpoints.
                if stopTime <= leadingTime && nextStopTime >= trailingTime {
                    
                    let leadingStopColor = interpolate(event, nextEvent, to: leadingTime)
                    let trailingStopColor = interpolate(event, nextEvent, to: trailingTime)
                    stops.append(.init(color: leadingStopColor, location: 0.0))
                    stops.append(.init(color: trailingStopColor, location: 1.0))
                    
                    break dayLoop // We've added the final stop
                }
                
                // Next, check if this event is the first event shown onscreen; if so interpolate the first endpoint.
                if stopTime <= leadingTime && nextStopTime >= leadingTime {
                    
                    let leadingStopColor = interpolate(event, nextEvent, to: leadingTime)
                    stops.append(.init(color: leadingStopColor, location: 0.0))
                    
                }
                
                // Next, check if both this event and the next event are shown onscreen; if so, no interpolation is needed.
                if stopTime >= leadingTime && nextStopTime <= trailingTime {
                    
                    // Add screenStop for event, converting timespace to unitspace.
                    stops.append(.init(color: event.0, location: timeline.unitX(fromTime: event.1)))
                }
                
                // Next check if this is the last event located onscreen.
                if stopTime <= trailingTime && nextStopTime >= trailingTime {
                    
                    // If so, we need to create two screenStops, one for the current event, and one at the trailing edge of the screen, interpolated between the current and next event.
                    
                    stops.append(.init(color: event.0, location: timeline.unitX(fromTime: event.1)))
                    let trailingStopColor = interpolate(event, nextEvent, to: trailingTime)
                    stops.append(.init(color: trailingStopColor, location: 1.0))
                    
                    break dayLoop // exit loop; we have added the final stop
                }
                
            } // end of stops loop
            
            day = nextDay
            
        } // End of dayLoop
        
        return stops
        
    } // End of updateScreenStops
    
    
    // MARK: - Interpolate
    // This function returns a new color, interpolated to match a new time between two given stops.
    static func interpolate(_ stop1: (Color, Double), _ stop2: (Color, Double), to newTime: Double) -> Color {
        
        let color1 = stop1.0
        let color2 = stop2.0
        let time1 = stop1.1
        let time2 = stop2.1
        
        let percent = (newTime - time1)/(time2 - time1)
        
        let a = color1.parts().hue; let b = color1.parts().saturation; let c = color1.parts().brightness
        let x = color2.parts().hue; let y = color2.parts().saturation; let z = color2.parts().brightness
        
        let newColor = Color(hue: a + (x-a)*percent, saturation: b + (y-b)*percent, brightness: c + (z-c)*percent)
        
        return newColor
    }
}
