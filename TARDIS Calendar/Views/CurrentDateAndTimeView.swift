//
//  CurrentTimeAndDateView.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 11/16/23.
//

import Foundation
import SwiftUI


struct CurrentDateAndTimeView: View {
    
    @EnvironmentObject var timeline: Timeline
    
    var formatter:DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MMM d"
        return formatter
    }
    
    var body: some View {
        
        let now = Date(timeIntervalSince1970: timeline.now)
        VStack {
            Text("Current Time")
                .font(.subheadline)
                .foregroundColor(.black)
                .autocapitalization(.allCharacters)
            Text(now, format: .dateTime.hour().minute())
            Text(formatter.string(from: now))
        }
        .padding(5)
        .background(.white)
        .opacity(0.75)
        .foregroundColor(.blue)
        .fontWeight(.black)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 5)))
    }
}
