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
    
    let eventManager = EventManager()
    
    static var dragStart = 0.0
    
    var body: some View {
        
        GeometryReader { screen in
            
            // Main ZStack layers background behind all else
            ZStack {
                
                // Background shows time of day by color
                BackgroundView(timeline: timeline)
                
                // Zoom in and out by changing trailingTime
                    .gesture(DragGesture()
                        .onChanged { gesture in
                            if ContentView.dragStart == 0.0 {
                                ContentView.dragStart = gesture.startLocation.x
                            }
                            let width = screen.size.width
                            // divide by width to convert to unit space
                            let start = ContentView.dragStart / width
                            let end = gesture.location.x / width
                            ContentView.dragStart = gesture.location.x
                            print("0, \(end), \(start), \(screen.size.width)")
                            guard end > Timeline.nowLocation && start > Timeline.nowLocation else {
                                return
                            }
                            timeline.newTrailingTime(start: start, end: end, completion: {
                                trailingTimeChanged in
                                if trailingTimeChanged {
                                    animateSpan = false
                                    inactivityTimer?.invalidate()
                                }
                            })
                        } .onEnded { _ in
                            ContentView.dragStart = 0.0
                            inactivityTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: false, block: {_ in animateSpan = true})
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
                
                // TODO: - update this function call to include now and end time as parameters
                ForEach(eventManager.eventViewArray(timeline: timeline), id: \.self.xLocation) { event in
                    event
                        .position(x: event.xLocation * screen.size.width, y: yOfTimeline * screen.size.height)
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
            }
            .onReceive(spanTimer) { time in
               // TODO: - update animation bringing calendar back to home zoom.
               // trailingTime = spanCalc(timeline: Timeline(now: now, trailingTime: trailingTime))
            }
            
        } // Close Geometry Reader
        
    } // Close View
    
    
    func spanCalc(timeline: Timeline) -> Double {
        
        
        if animateSpan {
            
            
            if abs(timeline.defaultSpan - timeline.span) > 0.05 {
                var base = 1.0
                if timeline.span < timeline.defaultSpan {
                    base = 0.99
                } else {
                    base = 0.95
                }
                let newSpan = timeline.defaultSpan + base * (timeline.span - timeline.defaultSpan)
                let newTrailingTime = timeline.leadingTime + newSpan
                print(newTrailingTime)
                return newTrailingTime
                
            } else {
                animateSpan = false
                return timeline.trailingTime
            }
            
        } else {
            return timeline.trailingTime
        }
    }
    
    
}




