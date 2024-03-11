//
//  Events.swift
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
    
    @Environment(\.dimensions) private var dimensions
    @Environment(\.timeline) private var timeline
    @EnvironmentObject var eventManager: EventManager
    @State var dismiss = false
    
    // Each veiw has an arrow on the timeline; this places it correctly. Do not adjust.
    let arrowOffset: Double = -7.75
    
    
    // MARK: Calculated Properties
       
    // This offset value keeps the event view centered over Now while the event is happening.
    var offsetAmount: Double {
        if event.isNow {
            return dimensions.width * (Timeline.nowLocation - timeline.unitX(fromTime: event.startDate.timeIntervalSince1970))
        } else {
            return 0.0
        }
    }
     
    // Makes dictionary of user calendars available; used to determine the calendar type for this event.
    var calendars: [String: String] =
    UserDefaults.standard.dictionary(forKey: UserDefaultKey.Calendars.rawValue) as? [String: String] ?? ["":""]
    
    
    // Each calendar type has an associated icon in the CalendarType enum.
    // Use the "daily" icon as a default in case something goes wrong.
    var icon: Image {
            
        if let icon = CalendarType(rawValue: calendars[event.calendarTitle] ?? CalendarType.daily.rawValue)?.icon() {
            return icon
        } else {
            return CalendarType.daily.icon()
        }
    }
    
    var color: Color {
        event.calendarColor
    }
    
    // shrinkFactor is passed in, but only use it to shrink low-priority event icons.
    var shrink: Double {
        return event.priority <= 2 ? shrinkFactor : 1.0
    }
    
    
    // MARK: IconView
    // Here is the "normal" icon-based event view, when it isn't expanded.
    var iconView: some View {
        
        ZStack {
            Circle()
                .foregroundColor(.yellow)
                .frame(width: dimensions.smallEvent * shrink, height: dimensions.smallEvent * shrink)
            icon
                .resizable()
                .foregroundColor(color)
                .frame(width: dimensions.smallEvent * 0.95 * shrink, height: dimensions.smallEvent * 0.95 * shrink)
        } // End of ZStack
        .onLongPressGesture(minimumDuration: 0.05, maximumDistance: 20.0) {
            eventManager.expandEvent(event)
        }
    } // End of iconView
    
    
    // MARK: ExpandedView
    var expandedView: some View {
        
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
                    icon
                        .resizable()
                        .foregroundColor(color)
                        .frame(width: dimensions.tinyEvent * 0.95, height: dimensions.tinyEvent * 0.95)
                }
                
                // Relative Time
                Text(event.relativeTimeDescription(event.startDate))
                    .font(.system(size: dimensions.fontSizeMedium))
                    .multilineTextAlignment(.center)
                
            } // End of content
            .frame(width: dimensions.largeEvent * 0.7, height: dimensions.largeEvent * 0.8)
            
        } // End of ZStack
        .onLongPressGesture(minimumDuration: 0.2, maximumDistance: 20.0) {
            eventManager.closeEvent(event)
            }
        
    } // End of expanded view
    
    
    // MARK: EventIsNowView
    var eventIsNowView: some View {
        
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
                
                Text("HAPPENING NOW")
                    .font(.system(size: dimensions.fontSizeSmall, weight: .bold))
                
                // Icon
                ZStack {
                    Circle()
                        .foregroundColor(.yellow)
                        .frame(width: dimensions.tinyEvent, height: dimensions.tinyEvent)
                    icon
                        .resizable()
                        .foregroundColor(color)
                        .frame(width: dimensions.tinyEvent * 0.95, height: dimensions.tinyEvent * 0.95)
                }
                
                // Relative Time
                Text(event.relativeTimeDescription(event.endDate))
                    .font(.system(size: dimensions.fontSizeMedium))
                    .multilineTextAlignment(.center)
                Text("TAP TO DISMISS")
                    .font(.system(size: dimensions.fontSizeSmall * 0.75, weight: .bold))
                    .foregroundColor(.blue)
                
            } // End of content
            .frame(width: dimensions.largeEvent * 0.7, height: dimensions.largeEvent * 0.8)
            
            
        } // End of ZStack
        .onTapGesture {
            dismiss = true
        }
        .alert("Are you finished with \(event.title)?", isPresented: $dismiss) {
            Button("YES") {
                event.event.endDate = Date()
                let range = Date()...Timeline.calendar.date(byAdding: .minute, value: 30, to: Date())!
                
                // If the next event is within half an hour, highlight it.
                if let _ = eventManager.events.first(where: {range.contains($0.startDate)}) {
                    eventManager.highlightNextEvent()
                }
            }
            Button("NO", role: .cancel) {
            }
        }
        
    } // End of EventIsNowView
    
    
    // MARK: Body
    // Here is the actual EventView, composed of its various parts.
    var body: some View {
        
//        let _ = Self._printChanges()
        
        // If the event has passed, present an empty view
        if event.endDate < Date() {
            
            EmptyView()
            
            // If the event is currently happening, present eventIsNowView
        } else if event.isNow {
            
            
            ArrowView (size: dimensions.largeEvent)
                .zIndex(0)
            eventIsNowView
                .offset(x:offsetAmount, y:0.0) // Keep the view at Now
                .zIndex(Double(20 + event.priority))
            
            
            // If the event is expanded, present expandedView
        } else if eventManager.isExpanded.contains(event.id) {
            
                ArrowView (size: dimensions.largeEvent)
                    .zIndex(0)
                expandedView
                    .zIndex(Double(event.priority + 10))
                        
            
            // Present default view
        } else {
            
            ArrowView (size: dimensions.smallEvent * shrink)
                .zIndex(0)
            iconView
                .zIndex(Double(event.priority))
            
        }
        
    } // End of view
    
} // End of struct

