//
//  ContentView.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 7/12/23.
//

import Foundation
import SwiftUI



struct ContentView: View {
    
    // TODO: - span should not be a @State variable; use now and endtime
    // TODO: - initialize instances of each class needed to generate view arrays: EventManager,
    
    @StateObject private var timeline = Timeline()
    @StateObject private var eventManager = EventManager()
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
            
            // Main ZStack layers background behind all else
            ZStack {
                
                // Background shows time of day by color
                BackgroundView(timeline: timeline)
                
                // Zoom in and out by changing trailingTime
                    .gesture(DragGesture()
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
                            // Make sure we aren't "out of bounds"; if we allow dragging across "now", bad things happen.
                            guard end > Timeline.nowLocation && start > Timeline.nowLocation else {
                                return
                            }
                            // This call actually changes the trailing time in our timeline, if we haven't gone beyond the boundaries.
                            timeline.newTrailingTime(start: start, end: end, completion: {
                                trailingTimeChanged in
                                if trailingTimeChanged {
                                    // This indicates user interaction, so reset the inactivity timer.
                                    animateSpan = false
                                    inactivityTimer?.invalidate()
                                }
                            })
                        } .onEnded { _ in
                            // When the drag ends, reset the starting value to zero to indicate no drag is happening at the moment.
                            ContentView.dragStart = 0.0
                            // And reset the inactivity timer, since this indicates the end of user interaction.
                            // When this timer goes off, the screen animates back to default zoom position.
                            inactivityTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: false, block: {_ in
                                animateSpan = true
                            })
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
                
                ForEach(eventManager.eventViews, id: \.self.event.startDate) { view in
                    view
                        .position(x: timeline.unitX(fromTime: view.event.startDate.timeIntervalSince1970) * screen.size.width, y: yOfTimeline * screen.size.height)
                }
                
                
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
            .ignoresSafeArea()
            .onAppear{eventManager.updateEvents()}
            .onReceive(updateTimer) { time in
                timeline.updateNow()
                print(timeline.now)
                // Every new day update the calendar events and solar events for backdrop.
                let today = Timeline.calendar.dateComponents([.day], from: Date())
                if today != currentDay {
                    eventManager.updateEvents()
                    currentDay = today
                }
            }
            .onReceive(spanTimer) { time in
                if animateSpan {changeSpan()}
            }
            .onTapGesture {
                print("TAP")
                eventManager.closeAll()
            }


            
        } // Close Geometry Reader
        
    } // Close View
    
    
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
    
    
}




