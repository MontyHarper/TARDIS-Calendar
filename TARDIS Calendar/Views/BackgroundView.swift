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

struct BackgroundView: View {
    
    var timeline: Timeline
    var solarEventManager: SolarEventManager
    
    var body: some View {
        
        LinearGradient(gradient: Gradient(stops: ScreenStops.generate(for: solarEventManager.solarDays, timeline: timeline)), startPoint: .leading, endPoint: .trailing)
            .ignoresSafeArea()
    }
}
