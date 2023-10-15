//
//  BackgroundView.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 10/13/23.
//

import Foundation
import SwiftUI

// This view is created once per second, to adjust for changes over time.
// This view is also re-created when the user changes the span of the screen.
// It would probably be more efficient to create the screenStops array once, then adjust the horizontal zoom level to match the span of the screen.

struct BackgroundView: View {
    
    var span: Double
    var now: Date
    
    var body: some View {
        
        LinearGradient(gradient: Gradient(stops: screenStops(span: span, now: now)), startPoint: .leading, endPoint: .trailing)
            .ignoresSafeArea()
        
    }
}
