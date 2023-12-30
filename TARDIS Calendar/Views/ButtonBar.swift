//
//  NextButtons.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 12/23/23.
//

import Foundation
import SwiftUI


struct ButtonModel: Identifiable {
    
    var eventManager: EventManager
    var id: String
    var image: Image
    var color: Color
    var topText: String
    var bottomText: String
    var action: (Timeline)->Void
   
    init(eventManager: EventManager, id: String) {
        self.eventManager = eventManager
        self.id = id
        
        switch id {
            
        case "first":
            image = Image(systemName: "circle.circle.fill")
            color = .blue
            topText = "NEXT"
            bottomText = "event"
            action = {timeline in
                let targetEvent = eventManager.events.first(where: {$0.startDate > Date()})
                timeline.setTargetSpan(date: targetEvent?.startDate)
                if let targetEvent = targetEvent {
                    eventManager.expandEvent(event: targetEvent)
                }
                StateBools.shared.animateSpan = true

            }
            
        case "all":
            image = Image(systemName: "arrow.left.and.right.circle.fill")
            color = .blue
            topText = "ALL"
            bottomText = "events"
            action = {timeline in
                let targetEvent = eventManager.events.last(where: {$0.startDate > Date()})
                timeline.setTargetSpan(date: targetEvent?.startDate)
                StateBools.shared.animateSpan = true
            }
            
        default:
            image = CalendarType(rawValue: id)?.icon() ?? Image(systemName: "questionmark.circle.fill")
            let targetEvent = eventManager.events.first(where: {$0.type == id && $0.startDate > Date()})
            color = targetEvent?.calendarColor ?? .blue
            topText = "NEXT"
            bottomText = (id == "meals") ? "meal" : id
            action = {timeline in
                 let targetEvent = eventManager.events.first(where: {$0.type == id && $0.startDate > Date()})
                timeline.setTargetSpan(date: targetEvent?.startDate)
                if let targetEvent = targetEvent {
                    eventManager.expandEvent(event: targetEvent)
                }
                StateBools.shared.animateSpan = true
            }
        }
    }
}


struct ButtonView: View {
    
    var size: Dimensions
    var button: ButtonModel
    @EnvironmentObject var timeline: Timeline
    
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
                    Text(button.topText)
                        .font(.system(size: size.fontSizeSmall, weight: .bold))
                        .offset(y: -0.55 * size.tinyEvent)
                        .lineLimit(1)
                }
                .overlay {
                    Text(button.bottomText)
                        .font(.system(size: size.fontSizeSmall, weight: .bold))
                        .offset(y: 0.55 * size.tinyEvent)
                }
        } // End of ZStack
        .onLongPressGesture(minimumDuration: 0.05, maximumDistance: 20.0) {
            button.action(timeline)
        }
    }
}


struct ButtonBar: View {
    
    @EnvironmentObject var size: Dimensions
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
                        ButtonView(size: size, button: button)
                    }
                }
                
            }
            .padding(EdgeInsets(top: 2, leading: 2, bottom: 5, trailing: 2))
            
            // spacer to keep button bar from abutting trailing edge
            Color(.clear)
                .frame(width: size.width * 0.05, height: 20.0)
        }
    }
}

