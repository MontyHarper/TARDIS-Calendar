//
//  EventView.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 8/2/23.
//
//  Displays each event as a circle with an icon, which can be expanded to show more information.
//

import EventKit
import SwiftUI

struct EventView: View {
    
    let event: Event
    let shrinkFactor: Double
    // This offset value keeps the event view centered over Now while the event is happening.
    var offsetAmount: Double 
    
    @Environment(\.dimensions) private var dimensions
    @EnvironmentObject var eventManager: EventManager
    
    // Each veiw has an arrow on the timeline; this places it correctly. Do not adjust.
    let arrowOffset: Double = -7.75
    
    
    // MARK: Calculated Properties
       
        
    var color: Color {
        event.calendarColor
    }
    
    // shrinkFactor is passed in, but only use it to shrink low-priority event icons.
    var shrink: Double {
        return event.priority <= 2 ? shrinkFactor : 1.0
    }
    
    // MARK: - Body
    
    var body: some View {
        
        let _ = Self._printChanges()
        
        // If the event has passed, present an empty view
        if event.endDate < Date() {
            
            EmptyView()
            
            // If the event is currently happening, present eventIsNowView
        } else if event.isNow {
            
            
            ArrowView (size: dimensions.largeEvent)
                .zIndex(0)
            EventIsNowView(event: event)
                .offset(x:offsetAmount, y:0.0) // Keep the view at Now
                .zIndex(Double(20 + event.priority))
            
            
            // If the event is expanded, present expandedView
        } else if eventManager.isExpanded.contains(event.id) {
            
            ArrowView (size: dimensions.largeEvent)
                .zIndex(0)
            ExpandedEventView(event: event)
                .zIndex(Double(event.priority + 10))
            
            
            // Present default view
        } else {
            
            ArrowView (size: dimensions.smallEvent * shrink)
                .zIndex(0)
            IconEventView(event: event, shrink: shrink)
                .zIndex(Double(event.priority))
            
        }
        
    } // End of view
    
} // End of struct

