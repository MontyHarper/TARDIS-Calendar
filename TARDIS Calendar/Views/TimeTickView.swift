//
//  TimeTickView.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 10/13/23.
//

import Foundation
import SwiftUI


// Will probably want to keep this but just use it to put the little triangle markers across the screen.
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
