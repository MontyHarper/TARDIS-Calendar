//
//  BackgroundView.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 10/13/23.
//
//  Background View is a color gradient with many stops, representing day, night, sunrise, and sunset.
//

import Foundation
import SwiftUI

// The stops array is re-created once per second, to adjust for changes over time.
// This view is also re-created when the user changes the span of the screen.

struct BackgroundView: View {
    
    @EnvironmentObject var solarEventManager: SolarEventManager
    
    var body: some View {
        
        LinearGradient(gradient: Gradient(stops: ScreenStops(solarEventManager: solarEventManager).stops), startPoint: .leading, endPoint: .trailing)
            .ignoresSafeArea()
    }
}
