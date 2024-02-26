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
    
    
    // MARK: - Mutating Methods
    
    // This needs to be removed, if all goes well - it's been replaced by the same function in the Trailing class below...
    func newTrailingTime(start: Double, end: Double) -> Double {
        
        // Calculating a linear transformation that moves the start point to the end point while keeping now in the same location. The calculation is in unit space, and the resulting trailing time is converted and stored in time space.
        
        let m = (settings.nowLocation - start) / (settings.nowLocation - end) // slope
        
        let b = start - m * end // y-int
                
        let newTrailingTimeUnitSpace = m * 1.0 + b
        
        let newTrailingTime = timeX(fromUnit: newTrailingTimeUnitSpace)
        
        // Before changing the trailingTime, make sure the new trailingTime lies within the boundaries of time the calendar is capable of showing on screen. If not, set the new trailingTime to either the max or min possible as appropriate.
        if newTrailingTime > leadingTime + settings.minSpan && newTrailingTime < leadingTime + maxSpan {
            return newTrailingTime
        } else {
            if newTrailingTime <= leadingTime + settings.minSpan {
                return leadingTime + settings.minSpan
            }
            if newTrailingTime >= leadingTime + maxSpan {
                return leadingTime + maxSpan
            }
            // Should never get to this
            return leadingTime + maxSpan
        }
    }
    
    // As I refactor I may not need this function; I think timeline will be re-initiated with changes to now or trailing time?
    func updateNow() {
        now = Date().timeIntervalSince1970
        trailingTime += 1.0
    }
    
    // As I refactor, this may need to change...
    func resetZoom() {
        trailingTime = Date().timeIntervalSince1970 + settings.defaultSpan // default trailingTime
    }
    
    
    // MARK: - Target Span
    
    // Target for zoom animation; will change based on time to the next event. Not sure if I will still need this...
    var targetSpan = TimelineSettings.shared.defaultSpan
    
    // This calculation takes a date and returns the span required to place that date onscreen at 0.8 on the unit scale. This assumes 0.2 is where Now is located. If I want to make this responsive to a change in the now location, I will need to refactor to take that into account.
    // This is used in setting the target of an auto zoom initiated by tapping the Now icon. The zoom will place the next event at 0.8 on the screen so it can easily be seen.
    func setTargetSpan(date: Date?) {
        if let date = date {
            let next = unitX(fromTime: date.timeIntervalSince1970)
            // transform takes .2 (now) to .2, and .8 to next; will take 0 to new leading edge, and 1 to new trailing, to calculate the new span.
            let transform: (Double) -> Double = {x in
                (x * (next - self.settings.nowLocation) - self.settings.nowLocation * next + 0.16) / 0.6
            }
            let targetTrailingUnit = transform(1.0)
            let targetLeadingUnit = transform(0.0)
            targetSpan = timeX(fromUnit: targetTrailingUnit) - timeX(fromUnit: targetLeadingUnit) // new target span is in time space.
            // Limit targetSpan to lie between minSpan and maxSpan
            if targetSpan < settings.minSpan {
                targetSpan = settings.minSpan
            }
            if targetSpan > maxSpan {
                targetSpan = maxSpan
            }
        } else {
            targetSpan = settings.defaultSpan
        }
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


// This is an experiment

class Trailing: ObservableObject {
    
    @Published var value: Double = Date().timeIntervalSince1970 + TimelineSettings.shared.defaultSpan {
        didSet {
            print(value)
        }
    }
    
    var timer: Timer?
    
    init() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {_ in
            self.value += 1.0
        }
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func newTrailingTime(start: Double, end: Double) {
        
        let timeline = Timeline(value)
        let settings = TimelineSettings.shared
        let leadingTime = timeline.leadingTime
        let maxSpan = timeline.maxSpan
        let minSpan = settings.minSpan
        
        // Calculating a linear transformation that moves the start point to the end point while keeping now in the same location. The calculation is in unit space, and the resulting trailing time is converted and stored in time space.
        
        let m = (settings.nowLocation - start) / (settings.nowLocation - end) // slope
        
        let b = start - m * end // y-int
                
        let newTrailingTimeUnitSpace = m * 1.0 + b
        
        let newTrailingTime = timeline.timeX(fromUnit: newTrailingTimeUnitSpace)
        
        // Before changing the trailingTime, make sure the new trailingTime lies within the boundaries of time the calendar is capable of showing on screen. If not, set the new trailingTime to either the max or min possible as appropriate.
        if newTrailingTime > leadingTime + minSpan && newTrailingTime < leadingTime + maxSpan {
            value = newTrailingTime
        } else {
            if newTrailingTime <= leadingTime + minSpan {
                value = leadingTime + minSpan
            } else {
                value = leadingTime + maxSpan
            }
        }
    }
}
