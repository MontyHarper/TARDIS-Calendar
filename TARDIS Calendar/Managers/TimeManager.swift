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
    
    // Setting targetTrailingTime to a new value triggers an animation to a screen with the target as the new trailingTime.
    var targetTrailingTime = Date().timeIntervalSince1970 + TimelineSettings.shared.defaultSpan {
        didSet {
            StateBools.shared.animateSpan = true
            print("new targetTrailingTime:" , targetTrailingTime)
        }
    }
    var updateTimer: Timer?
    var timeUnit: TimeInterval = 1.0 // How often to update in seconds
    
    init() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {_ in
            self.makeUpdates()
        }
    }
    
    deinit {
        updateTimer?.invalidate()
    }
    
    func makeUpdates() {
        
        // Advance trailing time - this effectively advances the timeline, triggering the UI to update.
        self.trailingTime += timeUnit
        
        // TODO: - is this still relevant?
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
        trailingTime = defaultTrailing()
    }
    
    func defaultTrailing() -> Double {
        let timeline = Timeline(trailingTime)
        let leadingTime = timeline.leadingTime
        let defaultSpan = TimelineSettings.shared.defaultSpan
        return leadingTime + defaultSpan
    }
    
    // This method takes a date and sets the targetTrailingTime required to place that date onscreen opposite the Now icon.
    // It then triggers an animation to that state by toggling the animation property.
    func setTarget(_ date: Date?) {
        
        guard let date = date else {
            targetTrailingTime = defaultTrailing()
            return
        }
        
        let timeline = Timeline(trailingTime)
        let now = TimelineSettings.shared.nowLocation
        let target = 1.0 - now
        let dateUnit = timeline.unitX(fromTime: date.timeIntervalSince1970)
        
        // transform is calculated to take now to now, and target (old value) to date (new value); thus it will take 0 to the new leading edge, and 1 to new trailing.
        let transform: (Double) -> Double = {x in
            x * ((now - dateUnit) / (now - target)) + now * ((dateUnit - target) / (now - target))
        }
        
        let targetLeadingUnit = transform(0.0)
        let targetTrailingUnit = transform(1.0)
        
        // Convert to time space
        let proposedLead = timeline.timeX(fromUnit: targetLeadingUnit)
        let proposedTarget = timeline.timeX(fromUnit: targetTrailingUnit)
        print("setTarget() - proposed target: ", proposedTarget)
        
        // Limit targetTrailingTime to lie between min and max
        let proposedSpan = proposedTarget - proposedLead
        if proposedSpan <= TimelineSettings.shared.minSpan {
            targetTrailingTime = TimelineSettings.shared.minSpan * (1.0 - TimelineSettings.shared.nowLocation) + Date().timeIntervalSince1970
        } else if proposedSpan >= timeline.maxSpan {
            targetTrailingTime = timeline.maxSpan * (1.0 - TimelineSettings.shared.nowLocation) + Date().timeIntervalSince1970
        } else {
            targetTrailingTime = proposedTarget
        }
    }
    
    // This function advances the animation for auto-zoom.
    // Note: I tried using SwiftUI animations; they don't work well for this.
    func newFrame() {
        if abs(targetTrailingTime - trailingTime) > 5 {
            trailingTime = trailingTime + 0.025 * (targetTrailingTime - trailingTime)
            print("animating ", trailingTime)
            
        } else {
            StateBools.shared.animateSpan = false
        }
    }
}
