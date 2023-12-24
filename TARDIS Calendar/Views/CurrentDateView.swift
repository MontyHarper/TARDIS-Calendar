//
//  CurrentTimeAndDateView.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 11/16/23.
//
//  This is exactly what it sounds like.
//  Current Date and Time should be very prominant and clear.
//  This probably needs more tweaking.
//

import Foundation
import SwiftUI

struct CurrentDateView: View {
    
    @EnvironmentObject var timeline: Timeline
    
    var formatter:DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter
    }
    
    var body: some View {
        
        let now = Date(timeIntervalSince1970: timeline.now)
        VStack {
            Text(formatter.string(from: now))
                .padding(EdgeInsets(top: 0.0, leading: 5.0, bottom: 9.0, trailing: 5.0))
                .background(.white)
                .foregroundColor(.blue)
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 5)))
        }
        .fontWeight(.black)
    }
}
