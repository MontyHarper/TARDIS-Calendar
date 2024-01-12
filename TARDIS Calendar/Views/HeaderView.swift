//
//  HeaderView.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 12/19/23.
//

import SwiftUI

struct HeaderView: View {
    
    @EnvironmentObject var size: Dimensions
    @EnvironmentObject var eventManager: EventManager
    @EnvironmentObject var timeline: Timeline
    
    var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: Date(timeIntervalSince1970: timeline.now))
    }
    var timeOfDayText: String {
        let hour = Timeline.calendar.component(.hour, from: Date(timeIntervalSince1970: timeline.now))
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
        UIFont.systemFont(ofSize: size.fontSizeMedium, weight: .black)
    }
    var marqueeFont: UIFont? {
        eventManager.marquee?.marqueeFont
    }
    var marqueeText: String? {
        eventManager.marquee?.message
    }
    var marqueeTextWidth: CGFloat? {
        marqueeText?.size(withAttributes: [.font: marqueeFont as Any]).width
    }
    var marqueeWidth: Double {
        min(size.width * 0.85, (marqueeTextWidth ?? size.width * 0.85) * 1.1)
    }
    var showMarquee: Bool {
        if let marqueeTextWidth = marqueeTextWidth {
            return (marqueeTextWidth > marqueeWidth)
        } else {
            return false
        }
    }
    
    var body: some View {
        
        ZStack {
            
            // Background
            Color(.clear)
                .frame(width: size.width, height: size.lineHeight * 5)
                .background(.regularMaterial)
            Color(.blue)
                .frame(width: size.width, height: size.lineHeight * 5)
                .opacity(0.3)
            
            VStack (spacing: 0.2 * size.lineHeight) {
                
                // Row 1: Time of day and today's date.
                Text(" \(timeOfDayText)! Today is \(dateText). ")
                    .fontWeight(.black)
                    .font(.system(size: size.fontSizeMedium, weight: .bold))
                    .foregroundColor(.blue)
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 5)))
                    .frame(height: size.fontSizeMedium * 1.5, alignment: .bottom)
                
                // Row 2: marquee text
                ZStack {
                    if showMarquee {
                        MarqueeView()
                    } else if let showText = marqueeText {
                        Text(" ★ \(showText)")
                            .font(Font(marqueeFont!))
                    } else {
                        EmptyView()
                    }
                }
                .frame(width: showMarquee ? marqueeWidth : 0.0, height: size.lineHeight, alignment: .center)
                .background(Color(hue: 0.0, saturation: 0.0, brightness: 1.0, opacity: 0.5))                .clipShape(RoundedRectangle(cornerRadius: 20))

                
                // Row 3: TimeTicks
                TimeTickBar()
                
            }
            
            
        } // End of ZStack
        .environmentObject(size)
    }
}


