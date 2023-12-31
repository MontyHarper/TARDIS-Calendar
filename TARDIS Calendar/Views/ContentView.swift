//
//  ContentView.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 7/12/23.
//
//  This is the calendar view. Mostly this is what we see when the app is running.
//

import Foundation
import SwiftUI

struct ContentView: View {
        
    // Access to view models
    @StateObject private var timeline = Timeline.shared
    @StateObject private var eventManager = EventManager()
    @StateObject private var solarEventManager = SolarEventManager()
    @StateObject private var stateBools = StateBools.shared
    
    // State variables
    @State private var inactivityTimer: Timer?
    @State private var currentDay = Timeline.calendar.dateComponents([.day], from: Date())
    
    // Constants that configure the UI. To mess with the look of the calendar, mess with these.
    let yOfLabelBar = 0.1 // y position of date label bar in unit space
    let yOfTimeline = 0.5
    let yOfInfoBox = 0.1
    
    // Timers driving change in the UI
    // May want to refactor for better efficiency
    // Josh says use timeline view?
    let updateTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    let spanTimer = Timer.publish(every: 0.04, on: .main, in: .common).autoconnect()
    
    // Used to track drag gesture for the one-finger zoom function.
    static private var dragStart = 0.0
    
    
    var body: some View {
        
        GeometryReader { screen in
            
            // MARK: - Zoom Gesture
            // Custom Zoom gesture attaches to the background and event views.
            // Needs to live here inside the geometry reader.
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
                    stateBools.animateSpan = false
                    inactivityTimer?.invalidate()
                    
                } .onEnded { _ in
                    // When the drag ends, reset the starting value to zero to indicate no drag is happening at the moment.
                    ContentView.dragStart = 0.0
                    // And reset the inactivity timer, since this indicates the end of user interaction.
                    // When this timer goes off, the screen animates back to default zoom position.
                    inactivityTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: false, block: {_ in
                        stateBools.animateSpan = false // Turning this off for now to see how we like the app without this feature.
                    })
                }
            
            // MARK: - View Elements
            
            // Main ZStack layers background behind all else
            ZStack {
                
                // Background shows time of day by color
                BackgroundView(timeline: timeline, solarEventManager: solarEventManager)
                    .opacity(1.0)
                    .zIndex(-100)
                // Zoom in and out by changing trailingTime
                    .gesture(oneFingerZoom)

                
                // Show progress view while background loads.
                if stateBools.showProgressView {
                    ProgressView()
                        .position(x: screen.size.width * 0.5, y: screen.size.height * 0.5)
                        .scaleEffect(3)
                }
                
                
                
                
                // View on top of background is arranged into three groups; Header, which include current date, marquee, and time ticks, timeline for events, and "next" buttons. Grouping is just conceptual, and needed because there are more than ten items in this ZStack. Individual elements are placed exactly.
                
                
                // headerView combines current date, marquee with scrolling messages, and time tick markers.
                HeaderView()
                    .position(x: screen.size.width * 0.5, y: screen.size.height * yOfLabelBar)
                
                
                // Hidden button in upper right hand corner allows caregivers to change preferences.
                Color(.clear)
                    .frame(width: 80, height: 80)
                    .contentShape(Rectangle())
                    .position(x: screen.size.width - 40, y: 40)
                    .onTapGesture(count: 3, perform: {
                        stateBools.showSettingsAlert = true
                    })
                    .alert("Do you want to change the settings?", isPresented: $stateBools.showSettingsAlert) {
                        Button("No - Touch Here to Go Back", role: .cancel, action: {})
                        Button("Yes", action: {stateBools.showSettings = true})
                    }
                    .sheet(isPresented: $stateBools.showSettings) {
                        SettingsView(eventManager: eventManager)
                            .onDisappear {
                                eventManager.updateEvents()
                            }
                    }
                
                // eventTimelineView combines a horizontal timeline with views for each event and a "nowView" that marks the current moment.
                EventTimelineView()
                    .gesture(oneFingerZoom)
                
                
                // Navigation buttons; each button represents a type of event and pulls the next event of that type onto the screen.
                
                ButtonBar()
                    .position(x: screen.size.width * 0.5, y: screen.size.height * 0.85)
                
                
                
                AlertView()
                
                
                
            } // End of main ZStack
            .statusBarHidden(true)
            .environmentObject(timeline)
            .environmentObject(eventManager)
            .environmentObject(Dimensions(screen.size))
            
            // Update timer fires once per second.
            .onReceive(updateTimer) { time in
                
                // Advance the timeline
                timeline.updateNow()
                print(timeline.now)
                
                // Check for new day; update calendar and solar events once per day.
                let today = Timeline.calendar.dateComponents([.day], from: Date())
                if today != currentDay {
                    print("called update calendars from new day in contentview")
                    eventManager.updateCalendarsAndEvents()
                    solarEventManager.updateSolarDays(){_ in}
                    currentDay = today
                }
                
                // Update marquee and/or next buttons if either has expired.
                
                if let marquee = eventManager.marquee {
                    if Date() > marquee.refreshDate {
                        eventManager.makeBanners()
                    }
                }
                
                if eventManager.buttonsExpire < Date() {
                    eventManager.makeButtons()
                }
                
            }
            
            // Animating zoom's return to default by hand
            .onReceive(spanTimer) { time in
                if stateBools.animateSpan {changeSpan()}
            }
            
            // Tapping outside an event view closes all expanded views
            .onLongPressGesture(minimumDuration: 0.05, maximumDistance: 20.0) {
                eventManager.closeAll()
            }

        } // End of Geometry Reader
        .ignoresSafeArea()


    } // End of ContentView
    
    
    // This function animates the calendar back to default zoom level.
    func changeSpan() {
        
        // Represents one frame - changes trailingTime toward the default time.
        // Maybe I can get swift to animate this?
        
        if abs(timeline.targetSpan - timeline.span) > 1 {
            let newSpan = timeline.span + 0.02 * (timeline.targetSpan - timeline.span)
            print(newSpan)
            let newTrailingTime = timeline.leadingTime + newSpan
            timeline.trailingTime = newTrailingTime
            
        } else {
            stateBools.animateSpan = false
        }
    }
}




