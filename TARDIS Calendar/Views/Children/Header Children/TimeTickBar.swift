//
//  TimeTickBar.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 12/22/23.
//

import SwiftUI

struct TimeTickBar: View {
    
    @Environment(\.dimensions) private var dimensions
    @Environment(\.timeline) private var timeline

    
    var body: some View {
        
        // TimeTick Markers
        
        Color(.clear)
            .frame(width: dimensions.width, height: dimensions.lineHeight)
            .background(.ultraThinMaterial)
            .frame(width: dimensions.width, height: dimensions.lineHeight * 1.5)

        // These put the white marks for unlabeled time intervals - trying to see how we do without them.
        
//        .overlay{
//            ForEach(
//                TimeTick.array(timeline: timeline), id: \.self.xLocation) {tick in
//                    TimeTickMarkerView(timeTick: tick)
//                        .position(x: size.width * tick.xLocation)
//                }
//                .offset(y: 0.73 * size.lineHeight)
//        }

        .overlay{
            // TimeTick Labels
            HorizontalLayoutNoOverlap{
                ForEach(
                    TimeTick.array(timeline: timeline), id: \.self.xLocation) {tick in
                        TimeTickLabelView(timeTick: tick)
                            .xPosition(tick.xLocation)
                    }
            }
            .frame(width: dimensions.width, height: dimensions.lineHeight)

        }
        
    }
}


