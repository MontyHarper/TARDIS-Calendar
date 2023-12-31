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
    
    @EnvironmentObject var size: Dimensions
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
                        .offset(y: size.lineHeight * 0.85))
        }
        .font(.system(size: size.fontSizeMedium, weight: xLocation == Timeline.nowLocation ? .black : .none))

    //    .background(.white)
    }
}

// The label tells where the marker is in time.
// Labels have markers that should mask the unlabeled mark underneath.
struct TimeTickLabelView: View, Identifiable {
    
    @EnvironmentObject var size: Dimensions
    var id = UUID()
    var timeTick: TimeTick
    var xLocation: Double {
        timeTick.xLocation
    }
    
    var body: some View {
        
        VStack {
            Text(timeTick.label)
                .opacity(xLocation == Timeline.nowLocation ? 1.0 : 0.5)
                .foregroundColor(.blue)
                .background(
                    Text("▼")
                        .opacity(0.75)
                        .foregroundColor(.blue)
                        .offset(y: size.lineHeight * 0.85))
        }
        .font(.system(size: xLocation == Timeline.nowLocation ? size.fontSizeMedium : size.fontSizeSmall, weight: xLocation == Timeline.nowLocation ? .black : .bold))
    }
    
}
