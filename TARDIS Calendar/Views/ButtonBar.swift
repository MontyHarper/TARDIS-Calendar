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
            
        // Note: just using bottomText for now, & not topText; keeping both properties while I decide if I need both.
        case "first":
            image = Image(systemName: "circle.circle.fill")
            color = .blue
            topText = "next"
            bottomText = "next"
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
            topText = "all"
            bottomText = "all"
            action = {timeline in
                let targetEvent = eventManager.events.last(where: {$0.startDate > Date()})
                timeline.setTargetSpan(date: targetEvent?.startDate)
                StateBools.shared.animateSpan = true
            }
            
        default:
            image = CalendarType(rawValue: id)?.icon() ?? Image(systemName: "questionmark.circle.fill")
            let targetEvent = eventManager.events.first(where: {$0.type == id && $0.startDate > Date()})
            color = targetEvent?.calendarColor ?? .blue
            topText = "next"
            bottomText = id
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

// MARK: Button View
struct ButtonView: View {
    
    var size: Dimensions
    var button: ButtonModel
    @EnvironmentObject var timeline: Timeline
    @State var rotateAmount: Double = 0.0
    
    var body: some View {
        
        ZStack {
            Circle()
                .foregroundColor(.yellow)
                .frame(width: size.tinyEvent, height: size.smallEvent)
            button.image
                .resizable()
                .foregroundColor(button.color)
                .frame(width: size.tinyEvent * 0.95, height: size.tinyEvent * 0.95, alignment: .center)
                
        } // End of ZStack
        .rotation3DEffect(.degrees(rotateAmount), axis: (x: 0.5, y: 0.5, z: 0))
        .overlay {
            Text(button.bottomText)
                .font(.system(size: size.fontSizeSmall, weight: .bold))
                .offset(y: 0.65 * size.tinyEvent)
                .lineLimit(1)
        }
        .foregroundColor(.blue)
        .onLongPressGesture(minimumDuration: 0.05, maximumDistance: 20.0) {
            withAnimation(.linear(duration: 0.75)) {
                rotateAmount += 360
            }
            button.action(timeline)
        }
    }
}


// MARK: Button Bar
struct ButtonBar: View {
    
    @EnvironmentObject var size: Dimensions
    @EnvironmentObject var eventManager: EventManager
    
    var body: some View {
        
        HStack {
            
            Spacer()
            
            ZStack {
                Color(.clear)
                    .frame(width: size.tinyEvent * Double(eventManager.buttons.count) * 1.20, height: size.tinyEvent * 1.4)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                
                HStack {
                    
                    ForEach(eventManager.buttons) {button in
                        ButtonView(size: size, button: button)
                    }
                    .offset(y: -0.1 * size.tinyEvent)
                }
                
            }
            .padding(EdgeInsets(top: 2, leading: 2, bottom: 5, trailing: 2))
            
            // spacer to keep button bar from abutting trailing edge
            Color(.clear)
                .frame(width: size.width * 0.05, height: 20.0)
        }
    }
}

