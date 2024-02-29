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
    @EnvironmentObject var size: Dimensions
    var timeline: Timeline

    let yOfTimeline = 0.5
    
    var body: some View {
        
        ZStack {
            // Background is a horizontal arrow across the screen
            Color(.black)
                .shadow(color: .white, radius: 3)
                .frame(width: size.width, height: size.timelineThickness)
                .position(x: 0.5 * size.width, y: yOfTimeline * size.height)
                .zIndex(-90)
            ArrowView(size: 0.0)
                .position(x: size.width, y: yOfTimeline * size.height)
            
            
            // Circles representing events along the time line
            
            ForEach(eventManager.events.indices.sorted(by: {$0 > $1}), id: \.self) { index in
                EventView(event: eventManager.events[index], timeline: timeline, isExpanded: $eventManager.isExpanded[index], shrinkFactor: shrinkFactor(), screenWidth: size.width)
                    .position(x: timeline.unitX(fromTime: eventManager.events[index].startDate.timeIntervalSince1970) * size.width, y: yOfTimeline * size.height)
            }

            
            // Circle representing current time.
            NowView()
                .position(x: TimelineSettings.shared.nowLocation * size.width, y: yOfTimeline * size.height)
                .onTapGesture {
                    eventManager.highlightNextEvent()
                }
        }
    }
    
    // This function provides a factor by which to re-size low priority event views, shrinking them as the calendar zooms out. This allows high priority events to stand out from the crowd.
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
}
