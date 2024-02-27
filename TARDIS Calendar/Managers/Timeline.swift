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

// MARK: - Settings

struct TimelineSettings {
    
    // Setting this up as a singleton, to provide numbers for constructing timelines.
    
    static var shared = TimelineSettings()
    
    var calendar = Calendar.autoupdatingCurrent
    
    // Constant values.
    let minSpan: TimeInterval = 3600 // minimum time shown on screen is one hour, in seconds
    let nowLocation: Double = 0.15 // Determines how far from left edge of screen the now icon is positioned.
    let maxFutureDays = 7
    let defaultSpan = Double(4 * 3600) // Represents four hours on screen
    
    private init() {
    }
    
    // Start of day on the first future day that won't show on the calendar.
    func maxDay() -> Date {
        return calendar.startOfDay(for: calendar.date(byAdding: .day, value: maxFutureDays + 1, to: Date())!)
    }
    
    // Start of day on the last past day that won't show on the calendar.
    func minDay() -> Date {
        let maxDate = calendar.date(byAdding: .day, value: maxFutureDays, to: Date())!.timeIntervalSince1970
        let now = Date().timeIntervalSince1970
        let minDate = calendar.startOfDay(for: Date(timeIntervalSince1970: now - nowLocation * (maxDate - now)/(1.0 - nowLocation)))
        return calendar.date(byAdding: .day, value: -1, to: minDate)!
    }
} // End TimelineSettings




class Timeline: ObservableObject {
    
    // MARK: - Defining Properties
    
    var now: Double
    var trailingTime: Double
    
    init() {
        now = Date().timeIntervalSince1970
        trailingTime = Date().timeIntervalSince1970 + TimelineSettings.shared.defaultSpan
    }
    
    init(_ trailingTime: Double) {
        self.now = Date().timeIntervalSince1970
        self.trailingTime = trailingTime
    }
    
    init(_ now: Double, _ trailingTime: Double) {
        self.now = now
        self.trailingTime = trailingTime
    }
    
    private let settings = TimelineSettings.shared
   
    // MARK: - Derived Properties
 
    
    // Maximum amount of time that can be depicted on screen in seconds.
    public var maxSpan: TimeInterval {
        let maxDate = settings.calendar.date(byAdding: .day, value: settings.maxFutureDays, to: Date())!.timeIntervalSince1970
        let minDate = now - settings.nowLocation * (maxDate - now)/(1.0 - settings.nowLocation)
        return maxDate - minDate
    }
    
    var today: Date {
        settings.calendar.startOfDay(for: Date())
    }
    
    var leadingTime: Double {
        return (now - settings.nowLocation * trailingTime) / (1 - settings.nowLocation)
    }
    var span: TimeInterval {
        return trailingTime - leadingTime
    }
    var leadingDate: Date {
        return Date(timeIntervalSince1970: leadingTime)
    }
    var trailingDate: Date {
        Date(timeIntervalSince1970: trailingTime)
    }
    
    
    // MARK: - Methods
    
    // linear transformation from time space to unit space.
    func unitX (fromTime time: Double) -> Double {
        let m = (1 - settings.nowLocation) / (trailingTime - now)
        let b = 1 - m * trailingTime
        return m * time + b
    }
    
    // linear transformation from unit space to time space.
    func timeX (fromUnit x: Double) -> Double {
        let m = (1 - settings.nowLocation) / (trailingTime - now)
        let b = 1 - m * trailingTime
        return (x - b) / m
    }
    
    
    // TODO: these functions don't belong in the timeline, since they don't rely on any timeline values
    
    // linear transformation from screen space to unit space. Note screen width must be an input; we only have access to that from ContentView.
    func unitX (fromScreen x: Double, width: Double) -> Double {
        return x / width
    }
    
    // linear transformation from unit space to screen space. Note screen width must be an input; we only have access to that from ContentView.
    
    func screenX (fromUnit x: Double, width: Double) -> Double {
        return x * width
    }
    
}



