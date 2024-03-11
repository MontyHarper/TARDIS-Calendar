//
//  TimeManager.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 2/26/24.
//
//  TimeManager updates the trailingTime, which is the time represented by the right-hand edge of the screen.
//  timeUnit determines how often the screen is refreshed and can be adjusted externally to match the smallest unit of time that makes a visual difference.
//  Setting the targetTrailingTime triggers TimeManager to gradually change the trailingTime to match the target, which creates an animation on screen from the current trailing time to the target time.
//

import Foundation

class TimeManager: ObservableObject {
    
    // MARK: - Key Properties
    
    @Published var trailingTime: Double = Date().timeIntervalSince1970 + Timeline.defaultSpan {
        didSet {
            print(trailingTime)
        }
    }
    
    // Setting targetTrailingTime to a new value triggers an animation to a screen with the target as the new trailingTime.
    public var targetTrailingTime = Date().timeIntervalSince1970 + Timeline.defaultSpan {
        didSet {
            StateBools.shared.animateSpan = true
            print("new targetTrailingTime:" , targetTrailingTime)
        }
    }
    
    private var updateTimer: Timer?
    
    // Setting timeUnit to a different value will change the rate at which the screen updates.
    public var timeUnit: TimeInterval = 1.0 // How often to update in seconds
    
    // MARK: - Init & Deinit
    
    init() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: timeUnit, repeats: true) {_ in
            self.makeUpdates()
        }
    }
    
    deinit {
        updateTimer?.invalidate()
    }
    
    // MARK: - Update Function
    
    private func makeUpdates() {
        // Advance trailing time - this advances the timeline, triggering the UI to update.
        self.trailingTime += timeUnit
    }
    
    // MARK: - Public Functions
    
    // This changes the trailingTime based on moving the given start location on screen to the given end location.
    // The one-finger-zoom gesture uses this function to zoom in and out along the calendar's timeline.
    func newTrailingTime(start: Double, end: Double) {
        
        let timeline = Timeline(trailingTime)
        let nowLocation = Timeline.nowLocation
        let leadingTime = timeline.leadingTime
        let maxSpan = timeline.maxSpan
        let minSpan = Timeline.minSpan
        
        // Calculating a linear transformation that moves the start point to the end point while keeping now in the same location. The calculation is in unit space, and the resulting trailing time is converted and stored in time space.
        
        let m = (nowLocation - start) / (nowLocation - end) // slope
        
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
    
    // Instantly resets zoom to the default level.
    func resetZoom() {
        let timeline = Timeline(trailingTime)
        let leadingTime = timeline.leadingTime
        let defaultSpan = Timeline.defaultSpan
        let defaultTrailing = leadingTime + defaultSpan
        trailingTime = defaultTrailing
    }
        
    // MARK: - Animation Functions
    
    // This method takes a date and sets the targetTrailingTime required to place that date onscreen opposite the Now icon,
    // which triggers an animation to the new zoom level.
    // This method is used by the navigation buttons to move around in the calendar timeline.
    func setTarget(_ date: Date?) {
        
        guard let date = date else {
            resetZoom()
            return
        }
        
        let timeline = Timeline(trailingTime)
        let now = Timeline.nowLocation
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
        if proposedSpan <= Timeline.minSpan {
            targetTrailingTime = Timeline.minSpan * (1.0 - Timeline.nowLocation) + Date().timeIntervalSince1970
        } else if proposedSpan >= timeline.maxSpan {
            targetTrailingTime = timeline.maxSpan * (1.0 - Timeline.nowLocation) + Date().timeIntervalSince1970
        } else {
            targetTrailingTime = proposedTarget
        }
    }
    
    // This function advances the zoom animation by a single frame.
    // This is called from a timer in the ContentView.
    // The timer is triggered when stateBools.animateSpan = true
    // Note: I tried using SwiftUI animations; they do not work well for this.
    func newFrame() {
        
        let closeEnough = 5.0 // Get this close to the target before stopping.
        let animationRate = 0.025 // bigger is faster
        
        if abs(targetTrailingTime - trailingTime) > closeEnough {
            
            trailingTime = trailingTime + animationRate * (targetTrailingTime - trailingTime)
            print("animating ", trailingTime)
            
        } else {
            // Stop animating
            StateBools.shared.animateSpan = false
        }
    }
}
