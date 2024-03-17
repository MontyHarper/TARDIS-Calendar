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
    @EnvironmentObject var labelManager: LabelManager
    
    let switchToWeeks: Double = (40*60*60)/(1 - Timeline.nowLocation) // ~2 days
    
    var labels: [TimeTickLabel] {
        labelManager.timeTickLabels.filter({
            let span = timeline.span
            if $0.absoluteTime < Date.now.timeIntervalSince1970 && $0.labelType != .now {
                return false
            } else {
                switch $0.labelType {
                case .weekday: return span > switchToWeeks
                case .now: return true
                case .relative: return span < switchToWeeks
                case .hour: return span < switchToWeeks
                }
            }
        })
        .sorted() // Sort is REQUIRED for the HorizontalLayout view to work properly.
    }
    
    
    var body: some View {
                
        Color(.clear)
            .frame(width: dimensions.width, height: dimensions.lineHeight)
            .background(.ultraThinMaterial)
            .frame(width: dimensions.width, height: dimensions.lineHeight * 1.5)
        .overlay{
            // TimeTick Labels
            HorizontalLayoutNoOverlap{
                ForEach(labels, id: \.labelKey) {label in
                    let xLocation = xLocation(label)
                    TimeTickLabelView(labelText: label.labelText, xLocation: xLocation, isAtNowLocation: Timeline.nowLocation == xLocation)
                            .xPosition(xLocation)
                    }
            }
            .frame(width: dimensions.width, height: dimensions.lineHeight)

        }
    }
    
    func xLocation(_ label: TimeTickLabel) -> Double {
        label.labelKey == .Now ? Timeline.nowLocation : timeline.unitX(fromTime: label.absoluteTime)
    }
}


