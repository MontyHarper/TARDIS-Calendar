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
         
    @Environment(\.dimensions) private var dimensions
    @Environment(\.timeline) private var timeline
        
    var timeText: String {
        Date(timeIntervalSince1970: timeline.now).formatted(date: .omitted, time: .shortened)
    }
    var dayOfWeekText: String {
        Date().formatted(Date.FormatStyle().weekday(.wide))
    }
    
    static public var nowIcon: Image {
        if let altImage = UserDefaults.standard.value(forKey: UserDefaultKey.NowIcon.rawValue) as? Image {
            return altImage
        } else {
            // Default image for now icon.
            return Image(systemName:"person.circle.fill")
        }
    }
    
    var body: some View {
                

        Group {
            
            ZStack {

            VStack {
                Image(systemName: "arrowtriangle.up.fill")
                    .resizable()
                    .frame(width: dimensions.mediumEvent * 0.2, height: 0.24 * dimensions.height)
                HStack {
                    Image(systemName: "arrowtriangle.left.fill")
                        .resizable()
                        .frame(width: dimensions.width * 0.12, height: 0.27 * dimensions.mediumEvent)
                    Image(systemName: "arrowtriangle.right.fill")
                        .resizable()
                        .frame(width: dimensions.width * 0.12, height: 0.27 * dimensions.mediumEvent)
                }
                Image(systemName: "arrowtriangle.down.fill")
                    .resizable()
                    .frame(width: dimensions.mediumEvent * 0.2, height: 0.24 * dimensions.height)
            }
            .foregroundColor(.blue)
            .shadow(color: .white, radius: 20)
            
                Circle()
                    .frame(width: dimensions.mediumEvent, height: dimensions.mediumEvent).foregroundColor(.blue)
                    .shadow(color: .white, radius: dimensions.mediumEvent * 0.1)
                NowView.nowIcon
                    .resizable()
                    .aspectRatio(contentMode:.fit)
                    .frame(width:dimensions.mediumEvent * 0.9, height: dimensions.mediumEvent * 0.9, alignment:.center)
                    .clipShape(Circle())
            }
            
        } // End of Group
        .frame(width: dimensions.largeEvent * 1.5)
        .overlay{
            VStack {
                VStack {
                    Text("The time is")
                        .font(.system(size: dimensions.fontSizeSmall))
                    Text(" \(timeText) ")
                        .font(.system(size: dimensions.fontSizeLarge * 1.25, weight: .black))
                }
                .foregroundColor(.blue)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                
                Text(dayOfWeekText)
                    .font(.system(size: dimensions.fontSizeLarge))
                    .foregroundStyle(.ultraThinMaterial)
            }
            .offset(x: 0.0, y: dimensions.largeEvent * 0.7)
        }
    }
}



