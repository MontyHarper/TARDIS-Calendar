//
//  ButtonModel.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 1/24/24.
//

import Foundation
import SwiftUI

struct ButtonModel: Identifiable {
    
    var eventManager: EventManager
    var id: String
    var image: Image
    var color: Color
    var bottomText: String
    var action: (Timeline)->Void
   
    init(eventManager: EventManager, id: String) {
        self.eventManager = eventManager
        self.id = id
        
        switch id {
            
        case "first":
            image = Image(systemName: "circle.circle.fill")
            color = .blue
            bottomText = "next"
            action = {timeline in
                eventManager.highlightNextEvent(timeline: timeline)
            }
            
        case "all":
            image = Image(systemName: "arrow.left.and.right.circle.fill")
            color = .blue
            bottomText = "all"
            action = {timeline in
                eventManager.closeAll()
                let targetEvent = eventManager.events.last(where: {$0.startDate > Date()})
                timeline.setTargetSpan(date: targetEvent?.startDate)
                StateBools.shared.animateSpan = true
            }
            
        default:
            image = CalendarType(rawValue: id)?.icon() ?? Image(systemName: "questionmark.circle.fill")
            let targetEvent = eventManager.events.first(where: {$0.type == id && $0.startDate > Date()})
            color = targetEvent?.calendarColor ?? .blue
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
