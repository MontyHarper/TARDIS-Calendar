//
//  ContentView.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 7/12/23.
//

import Foundation
import SwiftUI



struct ContentView: View {
    
    // TODO: - initialize instances of each class needed to generate view arrays: EventManager,
    
    @StateObject private var timeline = Timeline()
    @StateObject private var eventManager = EventManager()
    @StateObject private var solarEventManager = SolarEventManager()
    @State private var animateSpan = false
    @State private var inactivityTimer: Timer?
    
    // Constants that configure the UI; to mess with the look of the calendar, mess with these
    let yOfLabelBar = 0.2 // y position of date label bar in unit space
    let yOfTimeline = 0.5
    let yOfInfoBox = 0.8
    
    // Timers driving change in the UI
    // May want to refactor for better efficiency
    // Josh says use timeline view
    let updateTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    let spanTimer = Timer.publish(every: 0.04, on: .main, in: .common).autoconnect()
    @State private var currentDay = Timeline.calendar.dateComponents([.day], from: Date())
    
    static private var dragStart = 0.0
    
    
    var body: some View {
        
        GeometryReader { screen in
            
            // Custom Zoom gesture attaches to the background and event views.
            // As far as I can tell it needs to live here inside the geometry reader.
            let oneFingerZoom = DragGesture()
                .onChanged { gesture in
                    // If this is a new drag starting, save the location.
                    if ContentView.dragStart == 0.0 {
                        ContentView.dragStart = gesture.startLocation.x
                    }
                    let width = screen.size.width
                    // Divide by width to convert to unit space.
                    let start = ContentView.dragStart / width
                    let end = gesture.location.x / width
                    // Save the location of this drag for the next event.
                    ContentView.dragStart = gesture.location.x
                    // Drag gesture needs to occur on the future side of now, far enough from now that it doesn't cause the zoom to jump wildly
                    guard end > Timeline.nowLocation + 0.1 && start > Timeline.nowLocation + 0.1 else {
                        return
                    }
                    // This call changes the trailing time in our timeline, if we haven't gone beyond the boundaries.
                    timeline.newTrailingTime(start: start, end: end)
                    
                    // This indicates user interaction, so reset the inactivity timer.
                    animateSpan = false
                    inactivityTimer?.invalidate()
                    
                } .onEnded { _ in
                    // When the drag ends, reset the starting value to zero to indicate no drag is happening at the moment.
                    ContentView.dragStart = 0.0
                    // And reset the inactivity timer, since this indicates the end of user interaction.
                    // When this timer goes off, the screen animates back to default zoom position.
                    inactivityTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: false, block: {_ in
                        animateSpan = true
                    })
                }
            
            
            // Main ZStack layers background behind all else
            ZStack {
                
                // Background shows time of day by color
                BackgroundView(timeline: timeline, solarEventManager: solarEventManager)
                // Zoom in and out by changing trailingTime
                    .gesture(oneFingerZoom)
                

                // Hidden button in upper right hand corner allows caregivers to change preferences.
                Color(.clear)
                    .frame(width: 80, height: 80)
                    .contentShape(Rectangle())
                    .position(x: screen.size.width - 40, y: 40)
                    .onTapGesture(count: 3, perform: {
                        print("TRIPLE TAP")
                    })
                    
                
                // View on top of background is arranged into three groups; label bar, timeline for events, and a box showing current information. Grouping is just conceptual. Individual elements are placed exactly.
                
                
                // Label Bar
                // Label bar background
                Color(.white)
                    .frame(width: screen.size.width, height: 0.065 * screen.size.height)
                    .position(x: 0.5 * screen.size.width, y: yOfLabelBar * screen.size.height)
                
                // Hour and day markers
                ForEach(
                    dateLabelArray(timeline: timeline), id: \.self.xLocation) {label in
                        
                        label
                            .position(x: label.xLocation * screen.size.width, y: yOfLabelBar * screen.size.height)
                    }
                
                // End of Label Bar
                
                
                // Timeline
                
                // Background is a horizontal line across the screen
                Color(.black)
                    .shadow(color: .white, radius: 3)
                    .frame(width: screen.size.width, height: 2)
                    .position(x: 0.5 * screen.size.width, y: yOfTimeline * screen.size.height)
                
                
                // Circles representing events along the time line
            
                ForEach(eventManager.events.indices.sorted(by: {$0 > $1}), id: \.self) { index in
                    EventView(event: eventManager.events[index], isExpanded: $eventManager.isExpanded[index], shrinkFactor: shrinkFactor())
                        .position(x: timeline.unitX(fromTime: eventManager.events[index].startDate.timeIntervalSince1970) * screen.size.width, y: yOfTimeline * screen.size.height)
                }
                .gesture(oneFingerZoom)
                
                                
                
                // Circle representing current time.
                NowView()
                    .position(x: 0.2 * screen.size.width, y: yOfTimeline * screen.size.height)
                
                
                // End of Timeline
                
                
                
                // Current Information Box
                
                // Current Date Label
                DateLabel(timeline: timeline)
                    .position(x: 0.2 * screen.size.width, y: yOfInfoBox * screen.size.height)
                
                // End of Information Box
                
                
            } // End of main ZStack
            
            
            // Update timer fires once per second.
                .onReceive(updateTimer) { time in
                    
                    // Advance the timeline
                    timeline.updateNow()
                    print(timeline.now)
                    
                    // Check for new day; update calendar and solar events once per day.
                    let today = Timeline.calendar.dateComponents([.day], from: Date())
                    if today != currentDay {
                        eventManager.updateEvents()
                        solarEventManager.updateSolarDays()
                        currentDay = today
                    }
                    
                    // Expand the EventView for events happening soon and un-expand the EventView for events recently finished.
                    eventManager.autoExpand()
            
                }
            
            // Animating zoom's return to default by hand
                .onReceive(spanTimer) { time in
                    if animateSpan {changeSpan()}
                }
            
            // Tapping outside an event view closes all expanded views
                .onTapGesture {
                    eventManager.closeAll()
                }
                                    
        } // End of Geometry Reader
        .ignoresSafeArea()
        
    } // End of ContentView
    
    
    func changeSpan() {
        
        // Represents one frame - changes trailingTime toward the default time.
        // Maybe I can get swift to animate this?
        
        if abs(Timeline.defaultSpan - timeline.span) > 1 {
            let newSpan = timeline.span + 0.02 * (Timeline.defaultSpan - timeline.span)
            print(newSpan)
            let newTrailingTime = timeline.leadingTime + newSpan
            timeline.trailingTime = newTrailingTime
            
        } else {
            animateSpan = false
        }
        
    }
    
    func shrinkFactor() -> Double {
        
        // This function provides a factor by which to re-size low priority event views, shrinking them as the calendar zooms out. This allows high priority events to stand out from the crowd.
        
        let x = timeline.span

        // min seconds on screen to trigger shrink effect; set for 12 hours
        let min = 12.0 * 60 * 60
        let max = timeline.maxSpan // seconds on screen where target size is reached
        let b = 0.2 // target size
        
        switch x {
        case 0.0..<min:
            return 1.0
        case min..<max:
            let result = (b - 1) * (x - min)/(max - min) + 1
            print("Function Call Shrink Factor: \(result)")
            return Double(result)
        default:
            return b
        }
        
    }
    
    
}




