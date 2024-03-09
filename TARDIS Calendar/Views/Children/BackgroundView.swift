//
//  BackgroundView.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 10/13/23.
//
//  Background View is a color gradient with many stops, representing day, night, sunrise, and sunset.
//

import SwiftUI

struct BackgroundView: View {
    
    @EnvironmentObject var dimensions: Dimensions
    @EnvironmentObject var solarEventManager: SolarEventManager
    @EnvironmentObject var timeline: Timeline
    
    var sNow: Double { // now in screen unit space
        TimelineSettings.shared.nowLocation
    }
    var gStart: Double { // leading gradient time
        solarEventManager.gradientStart
    }
    var gSpan: Double { // gradient time span
        solarEventManager.gradientSpan
    }
    var now: Double { // current time in seconds
        Date().timeIntervalSince1970
    }
    var gNow: Double { // current time in gradient unit space
        (now - gStart) / gSpan
    }
    var gTrail: Double { // trailing edge of screen in gradient unit space
        (timeline.trailingTime - gStart) / gSpan
    }
    
    var width: Double { // slope of our transformation is the width of the gradient in screen unit space
        
        (1 - sNow) / (gTrail - gNow)
    }
    
    var offset: Double { // y-int of our transformation is the offset in screen unit space
        
        (gTrail * sNow - gNow) / (gTrail - gNow)
    }
    
    
    var body: some View {
        
        LinearGradient(gradient: Gradient(stops: solarEventManager.screenStops), startPoint: .leading, endPoint: .trailing)
            .ignoresSafeArea()
            .frame(width: width * dimensions.size.width)
            .offset(x: offset * dimensions.size.width)
    }
}
