//
//  TimeTickView.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 10/13/23.
//
//  These are the views along the top of the calendar,
//  showing time intervals, like the ticks on a ruler.
//

import Foundation
import SwiftUI

// These are laid out using HorizontalLayoutNoOverlap, which removes labels that overlap.
// That's why we need separate marker and label views - so missing labels still show a marker.

// The Tick Marker is just a triangle marking the spot.
struct TimeTickMarkerView: View, Identifiable {
    
    @Environment(\.dimensions) private var dimensions

    var id = UUID()
    var timeTick: TimeTick
    var xLocation: Double {
        timeTick.xLocation
    }
    
    var body: some View {
        
        VStack {
            Text("•••")
                .foregroundColor(.white)
                .overlay(
                    Text("▼")
                        .foregroundColor(.white)
                        .opacity(1.0)
                        .offset(y: dimensions.lineHeight * 0.85))
        }
        .font(.system(size: dimensions.fontSizeMedium, weight: xLocation == Timeline.nowLocation ? .black : .none))

    //    .background(.white)
    }
}

// The label tells where the marker is in time.
// Labels have markers that should mask the unlabeled mark underneath.
struct TimeTickLabelView: View, Identifiable {
    
    @Environment(\.dimensions) private var dimensions

    var id = UUID()
    var timeTick: TimeTick
    var xLocation: Double {
        timeTick.xLocation
    }
    
    var body: some View {
        
        let nowLocation = Timeline.nowLocation
        
        VStack {
            Text(timeTick.label)
                .opacity(xLocation == nowLocation ? 1.0 : 0.5)
                .foregroundColor(.blue)
                .background(
                    Text("▼")
                        .opacity(0.75)
                        .foregroundColor(.blue)
                        .offset(y: dimensions.lineHeight * 0.85))
        }
        .font(.system(size: xLocation == nowLocation ? dimensions.fontSizeMedium : dimensions.fontSizeSmall, weight: xLocation == nowLocation ? .black : .bold))
    }
    
}
