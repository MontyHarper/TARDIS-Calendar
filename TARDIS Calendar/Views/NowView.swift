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
    @EnvironmentObject var size: Dimensions
    var timeText: String {
        Date(timeIntervalSince1970: timeline.now).formatted(date: .omitted, time: .shortened)
    }
    
    var body: some View {
        
        // TODO: - this is hard-wired for now. Will need to allow user to specify an image and retrieve it here from user defaults.
        
        let image = Image(systemName:"person.circle.fill")
        
        Group {
            
            VStack {
                Image(systemName: "arrowtriangle.up.fill")
                    .resizable()
                    .frame(width: size.mediumEvent * 0.2, height: 0.27 * size.height)
                Image(systemName: "arrowtriangle.down.fill")
                    .resizable()
                    .frame(width: size.mediumEvent * 0.2, height: 0.27 * size.height)
            }
            .foregroundColor(.blue)
            .shadow(color: .white, radius: 20)
            .zIndex(-1)
            
//            ArrowView(size: size.mediumEvent)
//                .zIndex(0)
            Circle()
                .frame(width: size.mediumEvent, height: size.mediumEvent).foregroundColor(.blue)
                .zIndex(9)
                .shadow(color: .white, radius: size.mediumEvent * 0.1)
            image
                .resizable()
                .aspectRatio(contentMode:.fit)
                .frame(width:size.mediumEvent * 0.9, height: size.mediumEvent * 0.9, alignment:.center)
                .clipShape(Circle())
                .zIndex(10)
            
        } // End of Group
        .frame(width: size.largeEvent * 1.5)
        .overlay{
            VStack {
                Text("The time is")
                    .font(.system(size: size.fontSizeSmall))
                Text(" \(timeText) ")
                    .font(.system(size: size.fontSizeLarge * 1.25, weight: .black))
            }
            .foregroundColor(.blue)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .offset(x: 0.0, y: size.largeEvent * 0.7)
        }
    }
}

    



