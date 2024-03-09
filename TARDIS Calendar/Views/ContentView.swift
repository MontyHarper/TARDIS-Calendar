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
            
            ZStack {
                
                // MARK: - Visual Elements
                
                // Background shows time of day by color
                BackgroundView()
                    .opacity(1.0)
                    .zIndex(-100)
                    .oneFingerZoom(width: screen.size.width, timeManager: timeManager)

                // headerView combines current date, marquee with scrolling messages, and time tick markers.
                HeaderView()
                    .position(x: screen.size.width * 0.5, y: screen.size.height * yOfLabelBar)
                
                // eventTimelineView combines a horizontal timeline with views for each event and a "nowView" that marks the current moment.
                EventTimelineView()
                    .oneFingerZoom(width: screen.size.width, timeManager: timeManager)
                
                // Navigation buttons; each button represents a type of event and pulls the next event of that type onto the screen.
                ButtonBar()
                    .position(x: screen.size.width, y: screen.size.height * 0.85)
                    .offset(x: -Double(eventManager.buttonMaker.buttons.count) * Dimensions(screen.size).buttonWidth * 0.5 - 20)
            
                
                // MARK: - Functional Elements
                
                // Show progress view while background loads.
                if stateBools.showProgressView {
                    ProgressView()
                        .scaleEffect(3)
                }
                
                // Hidden button in upper right-hand corner allows caregivers to change preferences.
                HiddenSettingsButton()
                    .position(x: screen.size.width, y: 0.0)
                
                // Shows alert messages at the bottom of the screen for internet failure, empty calendar, etc. Alerts can be tapped for more information.
                AlertView()
                
                
            } // End of main ZStack

            .onAppear {
                eventManager.timeManager = timeManager
            }
            .statusBarHidden(true)
            .environmentObject(Dimensions(screen.size))
            .environmentObject(Timeline(timeManager.trailingTime))
            
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




