//
//  Timeline.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 10/18/23.
//
//  For convenience, Timeline makes various constants and calculations available that have to do with
//  how the timeline is currently represented on screen.
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

struct Timeline {
    
    private var calendar = Calendar.autoupdatingCurrent
    
    // These constant values are set here.
    public let minSpan: TimeInterval = 3600 // minimum time shown on screen is one hour, in seconds
    public let nowLocation: Double = 0.2 // now icon is shown 1/5 of the way from left edge of screen
    public let maxFutureDays = 7
    public let hoursOnScreen = 4
    
    public var maxSpan: TimeInterval {
        let now = Date().timeIntervalSince1970
        let maxDay2 = calendar.date(byAdding: .day, value: maxFutureDays, to: Date())!.timeIntervalSince1970
        let maxDay1 = now - nowLocation * (maxDay2 - now)/(1.0 - nowLocation)
        return maxDay2 - maxDay1
    }
    
    public var defaultSpan: TimeInterval {
        Double (self.hoursOnScreen * 3600)
    }
    
    public var now: Double // current time in seconds
    public var span: TimeInterval // amount of time shown on screen in seconds; adjustable by user in real time.
    public var leadingDate: Date // Date and time represented by the left edge of the screen.
    public var trailingDate: Date // Date and time represented by the right edge of the screen.
    public var leadingTime: Double // time at the left edge of the screen in seconds.
    public var trailingTime: Double // time at the right edge of the screen in seconds.

    
    init(span: TimeInterval, now: Double) {
        self.now = now
        self.span = span
        leadingDate = Date(timeIntervalSince1970: now - Settings.shared.nowLocation * span)
        trailingDate = Date(timeIntervalSince1970: now + (1.0 - Settings.shared.nowLocation) * span)
        leadingTime = leadingDate.timeIntervalSince1970
        trailingTime = trailingDate.timeIntervalSince1970
    }
    
    
    
    func dateToDouble(_ x:Double) -> Double {
        
        // linear transformation changing a given date x into a percent length of the screen.
        
        return ((1.0 - Settings.shared.nowLocation) * x + Settings.shared.nowLocation * trailingTime - now) / (trailingTime - now)
    }
    
}
