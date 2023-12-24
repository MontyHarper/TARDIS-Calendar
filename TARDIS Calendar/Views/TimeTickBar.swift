//
//  TimeTickBar.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 12/22/23.
//

import SwiftUI

struct TimeTickBar: View {
    
    @EnvironmentObject var timeline: Timeline
    var size: Dimensions
    
    var body: some View {
        
        // TimeTick Markers
        
        Color(.white)
            .frame(width: size.width, height: size.lineHeight)

        .overlay{
            ForEach(
                TimeTick.array(timeline: timeline), id: \.self.xLocation) {tick in
                    TimeTickMarkerView(timeTick: tick)
                        .position(x: size.width * tick.xLocation)
                }
                .offset(y: 0.73 * size.lineHeight)
        }

        .overlay{
            // TimeTick Labels
            HorizontalLayoutNoOverlap{
                ForEach(
                    TimeTick.array(timeline: timeline), id: \.self.xLocation) {tick in
                        TimeTickLabelView(timeTick: tick)
                            .xPosition(tick.xLocation)
                    }
            }
            .frame(width: size.width, height: size.lineHeight)
            .offset(y: 0.15 * size.lineHeight)

        }
        
    }
}


