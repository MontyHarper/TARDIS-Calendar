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
            ForEach(eventManager.events.indices, id: \.self) { index in
                EventView(event: eventManager.events[index], isExpanded: $eventManager.isExpanded[index], shrinkFactor: shrinkFactor(), screenWidth: dimensions.width)
                    .position(x: timeline.unitX(fromTime: eventManager.events[index].startDate.timeIntervalSince1970) * dimensions.width, y: yOfTimeline * dimensions.height)
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
