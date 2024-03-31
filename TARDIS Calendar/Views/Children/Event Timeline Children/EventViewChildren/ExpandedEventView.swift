//
//  ExpandedEventView.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 3/11/24.
//

import SwiftUI

struct ExpandedEventView: View {
    
    var event: Event
    
    @Environment(\.dimensions) var dimensions
    @EnvironmentObject var eventManager: EventManager
    @Environment(\.timeline) var timeline
    
    var body: some View {
        ZStack {
            
            Color(.clear) // Background
                .frame(width: dimensions.largeEvent, height: dimensions.largeEvent)
                .background(.ultraThinMaterial, in: Circle())
            
            VStack { // Content
                
                // Title
                Text(event.title)
                    .font(.system(size: dimensions.fontSizeLarge, weight: .bold))
                    .multilineTextAlignment(.center)
                
                // Notes
                if let notes = event.event.notes {
                    Text(notes)
                        .multilineTextAlignment(.center)
                        .font(.system(size: dimensions.fontSizeSmall))
                }
                
                // Time
                Text(event.happensWhen)
                    .font(.system(size: dimensions.fontSizeMedium))
                
                // Icon
                ZStack {
                    Circle()
                        .foregroundColor(.yellow)
                        .frame(width: dimensions.tinyEvent, height: dimensions.tinyEvent)
                    event.calendarIcon
                        .resizable()
                        .foregroundColor(event.calendarColor)
                        .frame(width: dimensions.tinyEvent * 0.95, height: dimensions.tinyEvent * 0.95)
                }
                
                // Relative Time
                Text(event.relativeTimeDescription(event.startDate, from: Date(timeIntervalSince1970: timeline.now)))
                    .font(.system(size: dimensions.fontSizeMedium))
                    .multilineTextAlignment(.center)
                
            } // End of content
            .frame(width: dimensions.largeEvent * 0.7, height: dimensions.largeEvent * 0.8)
            
        } // End of ZStack
        .onLongPressGesture(minimumDuration: 0.2, maximumDistance: 20.0) {
            eventManager.closeEvent(event)
            }    }
}


