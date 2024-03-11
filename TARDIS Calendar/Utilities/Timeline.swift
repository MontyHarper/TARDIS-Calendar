//
//  Timeline.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 10/18/23.
//
//  Timeline makes various constants and calculations available that describe
//  the timeline currently represented on screen, based on the trailing time.
//

import Foundation
import SwiftUI

struct Timeline: EnvironmentKey {
    
    static var defaultValue: Self = Timeline()
    
    // MARK: - Settings
    
    static var calendar = Calendar.autoupdatingCurrent
    static let minSpan: TimeInterval = 3600 // minimum time showable on screen is one hour, in seconds
    static let nowLocation: Double = 0.15 // Distance of "Now" from leading edge of screen in unit space.
    static let maxFutureDays = 7
    static let defaultSpan = Double(4 * 3600) // Represents four hours on screen
    
    static var maxDay: Date {
        return calendar.startOfDay(for: calendar.date(byAdding: .day, value: maxFutureDays + 1, to: Date())!)
    }
    
    // Start of day on the last past day that won't show on the calendar.
    static var minDay: Date {
        let maxDate = calendar.date(byAdding: .day, value: maxFutureDays, to: Date())!.timeIntervalSince1970
        let now = Date().timeIntervalSince1970
        let minDate = calendar.startOfDay(for: Date(timeIntervalSince1970: now - nowLocation * (maxDate - now)/(1.0 - nowLocation)))
        return calendar.date(byAdding: .day, value: -1, to: minDate)!
    }
    
    // MARK: - Defining Properties
    
    var now: Double = Date().timeIntervalSince1970
    
    // Time in seconds represented by the trailing edge of the screen.
    // This is passed in; all other times are derived from this and the settings above.
    var trailingTime: Double
    
    init() {
        trailingTime = Date().timeIntervalSince1970 + Timeline.defaultSpan
    }
    
    init(_ trailingTime: Double) {
        self.trailingTime = trailingTime
    }
    
   
    // MARK: - Derived Properties
 
    
    // Maximum amount of time that can be depicted on screen in seconds.
    var maxSpan: TimeInterval {
        let maxDate = Timeline.calendar.date(byAdding: .day, value: Timeline.maxFutureDays, to: Date())!.timeIntervalSince1970
        let minDate = now - Timeline.nowLocation * (maxDate - now)/(1.0 - Timeline.nowLocation)
        return maxDate - minDate
    }
    
    var today: Date {
        Timeline.calendar.startOfDay(for: Date())
    }
    
    // Time in seconds represented by leading edge of the screen.
    var leadingTime: Double {
        return (now - Timeline.nowLocation * trailingTime) / (1 - Timeline.nowLocation)
    }
    
    //Time interval in seconds represented by the entire screen.
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
}

extension EnvironmentValues {
    var timeline: Timeline {
        get { self[Timeline.self] }
        set { self[Timeline.self] = newValue }
    }
}

extension View {
    func insertTimelineIntoEnvironment(_ trailingTime: Double) -> some View {
        environment(\.timeline, Timeline(trailingTime))
    }
}
