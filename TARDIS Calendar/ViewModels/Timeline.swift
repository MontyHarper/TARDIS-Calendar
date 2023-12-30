//
//  Timeline.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 10/18/23.
//
//  Timeline makes various constants and calculations available that describe
//  the timeline currently represented on screen.
//

    /*
     defaultSpan = the span of time in seconds the screen reverts to after some period of no user interaction
     hoursOnScreen = the default number of hours roughly depicted on screen
     leadingDate = the Date represented by the left edge of the screen
     leadingTime = time at the left edge of the screen in seconds since 1970
     maxFutureDays = the maximum number of days the calendar will show, stored in user defaults
     maxSpan = the maximum allowable span of time represented onscreen, in seconds
     minSpan = the minimum allowable span of time represented onscreen, in seconds
     now = current time in seconds
     nowLocation = the x-value of the location on screen representing the current time, in unit space
     trailingDate = the Date represented by the right edge of the screen
     trailingTime = time at the right edge of the screen in seconds since 1970
     xPosition(date:) = converts a date into an x-value in unit space
     xPosition(time:) = converts time given in seconds since 1970 into an x-value in unit space
    */

import Foundation
import SwiftUI

class Timeline: ObservableObject {
    
    // Setting up timeline as a singleton so its properties and methods can be accessed from anywhere.
    static var shared = Timeline()
    
    // These two values define any given timeline.
    @Published var now: Double // current time in seconds
    @Published var trailingTime: Double // time at the right edge of the screen in seconds.
    
    // Private init so we can be sure there is only one timeline for the whole app.
    private init() {
        now = Date().timeIntervalSince1970
        trailingTime = Date().timeIntervalSince1970 + Timeline.defaultSpan // default trailingTime
    }
    
    static var calendar = Calendar.autoupdatingCurrent
    
    // These constant values are set here and made available across instances.
    static let minSpan: TimeInterval = 3600 // minimum time shown on screen is one hour, in seconds
    static let nowLocation: Double = 0.15 // Determines how far from left edge of screen the now icon is positioned.
    static let maxFutureDays = 7
    static let hoursOnScreen = 4 // Default number; screen returns to this when triggered.
    static var defaultSpan: TimeInterval { // represents seconds onscreen: 14400
        Double (Timeline.hoursOnScreen * 3600)
    }
    
    var targetSpan = Double (Timeline.hoursOnScreen * 3600) // Target for zoom animation; will change based on time to the next event.
    
    // Calculated values all stem from the variables now & trailing time, plus the constants set up above.
    
    // Maximum amount of time that can be depicted on screen in seconds.
    public var maxSpan: TimeInterval {
        let now = Date().timeIntervalSince1970
        let maxDate = Timeline.calendar.date(byAdding: .day, value: Timeline.maxFutureDays, to: Date())!.timeIntervalSince1970
        let minDate = now - Timeline.nowLocation * (maxDate - now)/(1.0 - Timeline.nowLocation)
        return maxDate - minDate
    }
    
    // For calculating screen stops we may need to reach one caledar day earlier and one later than the edges of the screen permit.
    // Start of day on the latest date that could show on the calendar, plus one.
    static var maxDay: Date {
        return Timeline.calendar.startOfDay(for: Timeline.calendar.date(byAdding: .day, value: Timeline.maxFutureDays + 1, to: Date())!)
    }
    
    // Start of day on the earliest day that can show on the calendar, minus one.
    static var minDay: Date {
        let now = Date().timeIntervalSince1970
        let maxDate = Timeline.calendar.date(byAdding: .day, value: Timeline.maxFutureDays, to: Date())!.timeIntervalSince1970
        let minDate = Timeline.calendar.startOfDay(for: Date(timeIntervalSince1970: now - Timeline.nowLocation * (maxDate - now)/(1.0 - Timeline.nowLocation)))
        return Timeline.calendar.date(byAdding: .day, value: -1, to: minDate)!
    }
    
    static var today: Date {
        Timeline.calendar.startOfDay(for: Date())
    }
    
    public var leadingTime: Double {
        return (now - Timeline.nowLocation * trailingTime) / (1 - Timeline.nowLocation)
    }
    public var span: TimeInterval {
        return trailingTime - leadingTime
    }
    public var leadingDate: Date {
        return Date(timeIntervalSince1970: leadingTime)
    }
    public var trailingDate: Date {
        Date(timeIntervalSince1970: trailingTime)
    }
    
    // linear transformation from time space to unit space.
    func unitX (fromTime time: Double) -> Double {
        let m = (1 - Timeline.nowLocation) / (trailingTime - now)
        let b = 1 - m * trailingTime
        return m * time + b
    }
    
    // linear transformation from unit space to time space.
    func timeX (fromUnit x: Double) -> Double {
        let m = (1 - Timeline.nowLocation) / (trailingTime - now)
        let b = 1 - m * trailingTime
        return (x - b) / m
    }
    
    // linear transformation from screen space to unit space. Note screen width must be an input; we only have access to that from ContentView.
    func unitX (fromScreen x: Double, width: Double) -> Double {
        return x / width
    }
    
    // linear transformation from unit space to screen space. Note screen width must be an input; we only have access to that from ContentView.
    
    func screenX (fromUnit x: Double, width: Double) -> Double {
        return x * width
    }
    
    func newTrailingTime(start: Double, end: Double) {
        
        // Calculating a linear transformation that moves the start point to the end point while keeping now in the same location. The calculation is in unit space, and the resulting trailing time is converted and stored in time space.
        
        let m = (Timeline.nowLocation - start) / (Timeline.nowLocation - end) // slope
        
        let b = start - m * end // y-int
                
        let newTrailingTimeUnitSpace = m * 1.0 + b
        
        let newTrailingTime = timeX(fromUnit: newTrailingTimeUnitSpace)
        
        // Before changing the trailingTime, make sure the new trailingTime lies within the boundaries of time the calendar is capable of showing on screen.
        if newTrailingTime > leadingTime + Timeline.minSpan && newTrailingTime < leadingTime + maxSpan {
            trailingTime = newTrailingTime
        } else {
            if newTrailingTime <= leadingTime + Timeline.minSpan {
                trailingTime = leadingTime + Timeline.minSpan
            }
            if newTrailingTime >= leadingTime + maxSpan {
                trailingTime = leadingTime + maxSpan
            }
        }
    }
    
    // This is called once per second by a timer.
    // Now is set exactly to current time.
    // Trailing time increases by one second; recalculating would create circular dependencies, I think?
    // Because trailingTime would depend on span, which depends on trailingTime.
    // This should keep the span roughly the same over time, within one second.
    func updateNow() {
        now = Date().timeIntervalSince1970
        trailingTime += 1.0
    }
    

    func resetZoom() {
        trailingTime = Date().timeIntervalSince1970 + Timeline.defaultSpan // default trailingTime
    }
    
    // This calculation takes a date and returns the span required to place that date onscreen at 0.8 on the unit scale. This assumes 0.2 is where Now is located. If I want to make this responsive to a change in the now location, I will need to refactor to take that into account.
    // This is used in setting the target of an auto zoom initiated by tapping the Now icon. The zoom will place the next event at 0.8 on the screen so it can easily be seen.
    func setTargetSpan(date: Date?) {
        if let date = date {
            let next = unitX(fromTime: date.timeIntervalSince1970)
            // transform takes .2 (now) to .2, and .8 to next; will take 0 to new leading edge, and 1 to new trailing, to calculate the new span.
            let transform: (Double) -> Double = {x in
                (x * (next - Timeline.nowLocation) - Timeline.nowLocation * next + 0.16) / 0.6
            }
            let targetTrailingUnit = transform(1.0)
            let targetLeadingUnit = transform(0.0)
            targetSpan = timeX(fromUnit: targetTrailingUnit) - timeX(fromUnit: targetLeadingUnit) // new target span is in time space.
            // Limit targetSpan to lie between minSpan and maxSpan
            if targetSpan < Timeline.minSpan {
                targetSpan = Timeline.minSpan
            }
            if targetSpan > maxSpan {
                targetSpan = maxSpan
            }
        } else {
            targetSpan = Timeline.defaultSpan
        }
    }
}
