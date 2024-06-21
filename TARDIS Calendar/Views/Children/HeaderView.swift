//
//  HeaderView.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 12/19/23.
//

import SwiftUI

struct HeaderView: View {
    
    @Environment(\.dimensions) private var dimensions
    @Environment(\.timeline) private var timeline
    @EnvironmentObject var eventManager: EventManager
    
    
    var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: Date())
    }
    var timeOfDayText: String {
        let hour = Timeline.calendar.component(.hour, from: Date())
        switch hour {
        case 1...5:
            return "Time to Sleep"
        case 6...11:
            return "Good Morning"
        case 12...16:
            return "Good Afternoon"
        case 17...20:
            return "Good Evening"
        default:
            return "Time to Sleep"
        }
    }
    var dateFont: UIFont {
        UIFont.systemFont(ofSize: dimensions.fontSizeMedium, weight: .black)
    }
    
    var body: some View {
        
        ZStack {
            
            // Background
            Color(.clear)
                .frame(width: dimensions.width, height: dimensions.lineHeight * 5)
                .background(.regularMaterial)
            Color(.blue)
                .frame(width: dimensions.width, height: dimensions.lineHeight * 5)
                .opacity(0.3)
            
            VStack (spacing: 0.2 * dimensions.lineHeight) {
                
                // Row 1: Time of day and today's date.
                Text(" \(timeOfDayText)! Today is \(dateText). ")
                    .fontWeight(.black)
                    .font(.system(size: dimensions.fontSizeMedium, weight: .bold))
                    .foregroundColor(.blue)
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 5)))
                    .frame(height: dimensions.fontSizeMedium * 1.5, alignment: .bottom)
                
                // Row 2: marquee text
                
                if let marquee = eventManager.bannerMaker.marquee {
                    
                    MarqueeView(controller: marquee)
                    
                } else {
                    EmptyView()
                }
                                
                // Row 3: TimeTicks
                TimeTickBar()
            }
                
                
        } // End of ZStack
    }
}


