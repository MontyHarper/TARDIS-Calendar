//
//  IconEventView.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 3/11/24.
//

import SwiftUI

struct IconEventView: View {
    
    @Environment(\.dimensions) var dimensions
    @EnvironmentObject var eventManager: EventManager
    
    var event: Event
    var shrink: Double
    
    var body: some View {
        
        ZStack {
            Circle()
                .foregroundColor(.yellow)
                .frame(width: dimensions.smallEvent * shrink, height: dimensions.smallEvent * shrink)
            event.calendarIcon
                .resizable()
                .foregroundColor(event.calendarColor)
                .frame(width: dimensions.smallEvent * 0.95 * shrink, height: dimensions.smallEvent * 0.95 * shrink)
        } // End of ZStack
        .onLongPressGesture(minimumDuration: 0.05, maximumDistance: 20.0) {
            eventManager.expandEvent(event)
        }
    }
}


