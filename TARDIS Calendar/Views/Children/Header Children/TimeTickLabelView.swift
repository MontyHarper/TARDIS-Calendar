//
//  TimeTickLabelView.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 10/13/23.
//
//  These are the views along the top of the calendar,
//  showing time intervals, like the ticks on a ruler.
//

import Foundation
import SwiftUI

struct TimeTickLabelView: View {
    
    @Environment(\.dimensions) private var dimensions

    var labelText: String
    var xLocation: Double
    var isAtNowLocation: Bool
    
    var body: some View {
                
 //       let _ = Self._printChanges()

        VStack {
            Text(labelText)
                .opacity(isAtNowLocation ? 1.0 : 0.5)
                .foregroundColor(.blue)
                .background(
                    Text("▼")
                        .opacity(0.75)
                        .foregroundColor(.blue)
                        .offset(y: dimensions.lineHeight * 0.85))
        }
        .font(.system(size: isAtNowLocation ? dimensions.fontSizeMedium : dimensions.fontSizeSmall, weight: isAtNowLocation ? .black : .bold))
    }
    
}
