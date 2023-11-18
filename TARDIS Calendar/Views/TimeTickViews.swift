//
//  TimeTickView.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 10/13/23.
//

import Foundation
import SwiftUI

struct TimeTickMarkerView: View, Identifiable {
    
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
                        .foregroundColor(.blue)
                        .opacity(0.5)
                        .offset(y: 15.5))
        }
        .background(.white)
    }
}

struct TimeTickLabelView: View, Identifiable {
    
    var id = UUID()
    var timeTick: TimeTick
    var xLocation: Double {
        timeTick.xLocation
    }
    
    var body: some View {
        
        VStack {
            Text(timeTick.label)
                .foregroundColor(.blue)
                .opacity(0.5)
                .background(
                    Text("▼")
                        .foregroundColor(.blue)
                        .opacity(0.5)
                        .offset(y:15.5))
        }
        .background(.white)
    }
    
}

// MARK: -- Everything above this line replaces everything below

struct TimeTickView: View, Identifiable {
    
    var id = UUID()
    var labelText: String
    var xLocation: Double
    
    var body: some View {
        
            VStack {
                Text(labelText)
                    .background(.white)
                    // Render the label invisible if it only contains one character
                    // This is a way of thinning out the labels so they don't get overcrowded
                    .foregroundColor(labelText.count > 1 ? .blue : .white)
                    .opacity(0.5)
                    .overlay(
                        Text("▼").foregroundColor(.white)
                            .offset(y:15.5))
        }
    }
}
