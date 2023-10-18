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
    @State private var span: Double = Time.defaultSpan
    @State private var currentTime: Date = Date()
    @State private var animateSpan = false
    @State private var inactivityTimer: Timer?
    // @State private var detailView = false
    
    // Constants that configure the UI; to mess with the look of the calendar, mess with these
    let yOfLabelBar = 0.2 // y position of date label bar in unit space
    let yOfTimeline = 0.5
    let yOfInfoBox = 0.8
    
    // Timers driving change in the UI
    // May want to refactor for better efficiency
    // Josh says use timeline view
    let updateTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    let spanTimer = Timer.publish(every: 0.04, on: .main, in: .common).autoconnect()
    
    var body: some View {
        
        GeometryReader { screen in
            
            // Main ZStack layers background behind all else
            ZStack {
                
                // Background shows time of day by color
                BackgroundView(span: span, now: currentTime)
                
                // TODO: - Change zoom so it's based on end time, not span
                // Zoom in and out by changing span
                    .gesture(DragGesture().onChanged { gesture in
                        let change = (gesture.translation.width / screen.size.width) * span * 0.05
                        let newSpan = span - change
                        if newSpan > Time.minSpan && newSpan < Time.maxSpan {
                            span = newSpan
                            animateSpan = false
                            inactivityTimer?.invalidate()
                        }
                    } .onEnded { _ in
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
                    // TODO: - change date label call so it passes end time and now, not span
                    dateLabelArray(span: span, now: currentTime), id: \.self.xLocation) {label in
                        
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
                ForEach(eventViewArray(span: span), id: \.self.xLocation) { event in
                    event
                        .position(x: event.xLocation * screen.size.width, y: yOfTimeline * screen.size.height)
                }
                
                
                // Circle representing current time.
                NowView(time: currentTime)
                    .position(x: 0.2 * screen.size.width, y: yOfTimeline * screen.size.height)
                
                
                // End of Timeline
                
                
                
                // Current Information Box
                
                // Current Date Label
                DateLabel(now: currentTime)
                    .position(x: 0.2 * screen.size.width, y: yOfInfoBox * screen.size.height)
                
                // End of Information Box
                
                
            } // End of main ZStack
            .ignoresSafeArea()
            .onAppear{Events().loadEvents()}
            .onReceive(updateTimer) { time in
                currentTime = Date()
            }
            .onReceive(spanTimer) { time in
                span = spanCalc(span)
            }
            
        } // Close Geometry Reader
        
    } // Close View
    
    
    func spanCalc(_ span: Double) -> Double {
        
        
        if animateSpan {
            
            if abs(Time.defaultSpan - span) > 0.01 {
                var base = 1.0
                if span < Time.defaultSpan {
                    base = 0.99
                } else {
                    base = 0.95
                }
                let newSpan = Time.defaultSpan + base * (span - Time.defaultSpan)
                print(newSpan)
                return newSpan
                
            } else {
                animateSpan = false
                return span
            }
            
        } else {
            return span
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



