//
//  NowView.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 10/13/23.
//
//  This is the NOW Icon on the timeline.
//  Initially I gave it a detail view, but decided that was not needed.
//

import Foundation
import SwiftUI

struct NowView: View {
         
    @EnvironmentObject var timeline: Timeline
    var size: Dimensions
    var timeText: String {
        Date(timeIntervalSince1970: timeline.now).formatted(date: .omitted, time: .shortened)
    }
    
    var body: some View {
        
        // TODO: - this is hard-wired for now. Will need to allow user to specify an image and retrieve it here from user defaults.
        
        let image = Image(systemName:"person.circle.fill")
        
        ZStack {
            
            ArrowView(size: size.mediumEvent)
                .zIndex(-90)
            Circle()
                .frame(width: size.mediumEvent, height: size.mediumEvent).foregroundColor(.yellow)
                .shadow(color: .white, radius: size.mediumEvent * 0.1)
            image
                .resizable()
                .aspectRatio(contentMode:.fit)
                .frame(width:size.mediumEvent * 0.9, height: size.mediumEvent * 0.9, alignment:.center)
                .clipShape(Circle())
                .overlay{
                    Text(timeText)
                        .lineLimit(1)
                        .font(.system(size: size.fontSizeMedium, weight: .black))
                        .offset(x: 0.0, y: size.mediumEvent * 0.62)
                        .shadow(color: .white, radius:  size.mediumEvent * 0.1)
                }
        } // End of ZStack
    }
}





