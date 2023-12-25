//
//  NextButtons.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 12/23/23.
//

import Foundation
import SwiftUI


struct ButtonModel: Identifiable {
    
    var id = UUID()
    var type: CalendarType
    var nextEvent: Event
    
    var image: Image {
        type.icon()
    }
    var color: Color {
        nextEvent.calendarColor
    }
}


struct ButtonView: View {
    
    var size: Dimensions
    var button: ButtonModel
    @EnvironmentObject var timeline: Timeline
    @EnvironmentObject var eventManager: EventManager
    
    var body: some View {
        
        ZStack {
            Circle()
                .foregroundColor(.yellow)
                .frame(width: size.tinyEvent, height: size.smallEvent)
            button.image
                .resizable()
                .foregroundColor(button.color)
                .frame(width: size.tinyEvent * 0.95, height: size.tinyEvent * 0.95, alignment: .center)
                .overlay {
                    Text(button.type.rawValue)
                        .font(.system(size: size.fontSizeSmall, weight: .bold))
                        .offset(y: 0.55 * size.tinyEvent)
                        .lineLimit(1)
                }
                .overlay {
                    Text("NEXT")
                        .font(.system(size: size.fontSizeSmall, weight: .bold))
                        .offset(y: -0.55 * size.tinyEvent)
                }
        } // End of ZStack
        .onTapGesture {
            timeline.setTargetSpan(date: button.nextEvent.startDate)
            StateBools.shared.animateSpan = true
            eventManager.expandEvent(event: button.nextEvent)
            
        }
    }
}

struct ButtonBar: View {
    
    var size: Dimensions
    @EnvironmentObject var eventManager: EventManager
    
    var body: some View {
        
        
        HStack {
            
            Spacer()
            
            ZStack {
                Color(.white)
                    .frame(width: size.tinyEvent * Double(eventManager.buttons.count) * 1.20, height: size.tinyEvent * 1.4)
                    .opacity(0.65)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                
                HStack {
                    ForEach(eventManager.buttons) {button in
                        ButtonView(size: size, button: button)                }
                }
            }
            .padding(EdgeInsets(top: 2, leading: 2, bottom: 5, trailing: 2))
            
            
            Color(.clear)
                .frame(width: size.width * 0.1, height: 20.0)
        }
    }
}
