//
//  TimeManager.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 2/26/24.
//

import Foundation

class TimeManager: ObservableObject {
    
    @Published var trailingTime: Double = Date().timeIntervalSince1970 + TimelineSettings.shared.defaultSpan {
        didSet {
            print(trailingTime)
        }
    }
    
    @Published var today: Int = TimelineSettings.shared.calendar.dateComponents([.day], from: Date()).day! {
        didSet {
            print("day number: ", today)
        }
    }
    
    var timer: Timer?
    var timeUnit: TimeInterval = 1.0
    
    init() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {_ in
            self.makeUpdates()
        }
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func makeUpdates() {
        
        // Advance trailing time - this effectively advances the timeline, triggering the UI to update.
        self.trailingTime += timeUnit
        
        // Check if it's a new day; if so, update today
        let lastActiveDay = UserDefaults.standard.value(forKey: UserDefaultKey.LastActiveDay.rawValue) as? Int ?? today
        if lastActiveDay != today {
 //           solarEventManager.updateSolarDays()
            UserDefaults.standard.set(today, forKey: UserDefaultKey.LastActiveDay.rawValue)
            today = TimelineSettings.shared.calendar.dateComponents([.day], from: Date()).day!
        }
    }
    
    // This calculates a new trailing time based on moving the given start location on screen to the given end location.
    func newTrailingTime(start: Double, end: Double) {
        
        let timeline = Timeline(trailingTime)
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
            trailingTime = newTrailingTime
        } else {
            if newTrailingTime <= leadingTime + minSpan {
                trailingTime = leadingTime + minSpan
            } else {
                trailingTime = leadingTime + maxSpan
            }
        }
    }
    
    // Resets zoom to the default level.
    func resetTrailing() {
        
        let timeline = Timeline(trailingTime)
        let leadingTime = timeline.leadingTime
        let defaultSpan = TimelineSettings.shared.defaultSpan
        trailingTime = leadingTime + defaultSpan
    }
    
}
