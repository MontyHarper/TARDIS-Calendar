//
//  EventIsNowView.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 3/11/24.
//

import SwiftUI

struct EventIsNowView: View {
    
    @Environment(\.dimensions) var dimensions
    
    var event: Event
    
    @State var dismiss = false
    
    
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
                
                Text("HAPPENING NOW")
                    .font(.system(size: dimensions.fontSizeSmall, weight: .bold))
                
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
            }
            Button("NO", role: .cancel) {
            }
        }
    }
}



