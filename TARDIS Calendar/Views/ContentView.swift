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
    
    // Access to ViewModels
    @EnvironmentObject private var eventManager: EventManager
    @EnvironmentObject private var solarEventManager: SolarEventManager
    
    // State variables
    @StateObject private var timeManager = TimeManager()
    @StateObject private var screenStops = ScreenStops()
    @State private var stateBools = StateBools.shared
    @State private var inactivityTimer: Timer?
    
    // TODO: - remove these or move them to a settings singleton
    // Constants that configure the UI. To mess with the look of the calendar, mess with these.
    let yOfLabelBar = 0.1 // y position of date label bar in unit space
    let yOfTimeline = 0.5 // unused?
    let yOfInfoBox = 0.1 // unused?
    
    // This timer drives the animation when AutoZoom is engaged.
    let animationTimer = Timer.publish(every: 0.04, on: .main, in: .common).autoconnect()
        
    // Used to track drag for the OneFingerZoom gesture.
    static private var dragStart = 0.0

    
    var body: some View {
        
        GeometryReader { screen in
            
            // MARK: - OneFingerZoom Gesture
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
                    guard end > TimelineSettings.shared.nowLocation + 0.1 && start > TimelineSettings.shared.nowLocation + 0.1 else {
                        return
                    }
                    // This call changes the trailing time in our timeline, if we haven't gone beyond the boundaries.
                    
                    timeManager.newTrailingTime(start: start, end: end)
                    
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
                BackgroundView(stops: screenStops.stops)
                    .opacity(1.0)
                    .zIndex(-100)
                // Zoom in and out by changing trailingTime
                    .gesture(oneFingerZoom)
                
                // headerView combines current date, marquee with scrolling messages, and time tick markers.
                HeaderView(timeline: Timeline(timeManager.trailingTime))
                    .position(x: screen.size.width * 0.5, y: screen.size.height * yOfLabelBar)
                
                // eventTimelineView combines a horizontal timeline with views for each event and a "nowView" that marks the current moment.
                EventTimelineView(timeline: Timeline(timeManager.trailingTime))
                    .gesture(oneFingerZoom)
                
                // Show progress view while background loads.
                if stateBools.showProgressView {
                    ProgressView()
                        .position(x: screen.size.width * 0.5, y: screen.size.height * 0.5)
                        .scaleEffect(3)
                }
                
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
                        SettingsView()
                    }
                
                // Navigation buttons; each button represents a type of event and pulls the next event of that type onto the screen.
                
                ButtonBar()
                    .position(x: screen.size.width * 0.5, y: screen.size.height * 0.85)
                
                AlertView()
                
            } // End of main ZStack
            .onChange(of: timeManager.trailingTime) { trailingTime in
                Task {
                    await screenStops.updateStops(for: solarEventManager.solarDays, timeline: Timeline(trailingTime))
                }
            }
            .onAppear {
                eventManager.timeManager = timeManager
            }
            .statusBarHidden(true)
            .environmentObject(Dimensions(screen.size))

            // Animating auto-zoom
            .onReceive(animationTimer) { time in
                if stateBools.animateSpan {timeManager.newFrame()}
            }
            
            // Tapping outside an event view closes all expanded views
            .onLongPressGesture(minimumDuration: 0.05, maximumDistance: 20.0) {
                eventManager.closeAll()
            }
            
        } // End of Geometry Reader
        .ignoresSafeArea()
        
    } // End of ContentView

}




