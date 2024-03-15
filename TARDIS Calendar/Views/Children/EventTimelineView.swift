//
//  EventTimelineView.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 12/26/23.
//

import Foundation
import SwiftUI

struct EventTimelineView: View {
    
    @EnvironmentObject var eventManager: EventManager
    @Environment(\.dimensions) private var dimensions
    @Environment(\.timeline) private var timeline

    let yOfTimeline = 0.5
    
    var body: some View {
        
        ZStack {
            // Background is a horizontal arrow across the screen
            Color(.black)
                .shadow(color: .white, radius: 3)
                .frame(width: dimensions.width, height: dimensions.timelineThickness)
                .position(x: 0.5 * dimensions.width, y: yOfTimeline * dimensions.height)
                .zIndex(-90)
                .onAppear {
                    print("Timeline born.")
                }
            ArrowView(size: 0.0)
                .position(x: dimensions.width, y: yOfTimeline * dimensions.height)
            
            
            // Circles representing events along the time line
            ForEach(eventManager.events) { event in
                EventView(event: event, shrinkFactor: shrinkFactor(), offsetAmount: offset(for: event))
                    .position(x: timeline.unitX(fromTime: event.startDate.timeIntervalSince1970) * dimensions.width, y: yOfTimeline * dimensions.height)
            }
            
            // Circle representing current time.
            NowView()
                .position(x: Timeline.nowLocation * dimensions.width, y: yOfTimeline * dimensions.height)
                .onTapGesture {
                    eventManager.highlightNextEvent()
                }
                .onAppear {
                    print("NowView born.")
                }
        }
    }
    
    // This method provides a factor by which to re-size low priority event views, shrinking them as the calendar zooms out. This allows high priority events to stand out from the crowd.
    
    func shrinkFactor() -> Double {
        
        let x = timeline.span

        // min seconds on screen to trigger shrink effect; set for 8 hours
        let min = 8.0 * 60 * 60
        let max = timeline.maxSpan // seconds on screen where target size is reached
        let b = 0.35 // target size
        
        switch x {
        case 0.0..<min:
            return 1.0
        case min..<max:
            let result = (b - 1) * (x - min)/(max - min) + 1
            return Double(result)
        default:
            return b
        }
    }
    
    // This method provides the amount to offset an event that is happening now so that it's view stays centered over the NowView on screen.
    
    func offset(for event: Event) -> Double {
        if event.isNow {
            return dimensions.width * (Timeline.nowLocation - timeline.unitX(fromTime: event.startDate.timeIntervalSince1970))
        } else {
            return 0.0
        }
    }
}
