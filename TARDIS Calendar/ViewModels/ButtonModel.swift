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
    
    // TODO: - this can't be a custom Type
    @State private var stateBools = StateBools.shared
   
    init(eventManager: EventManager, id: String) {
        self.eventManager = eventManager
        self.id = id
        
        switch id {
            
        case "first":
            image = Image(systemName: "circle.circle.fill")
            color = .blue
            bottomText = "next"
            
        case "all":
            image = Image(systemName: "arrow.left.and.right.circle.fill")
            color = .blue
            bottomText = "all"
            
        default:
            image = CalendarType(rawValue: id)?.icon() ?? Image(systemName: "questionmark.circle.fill")
            let targetEvent = eventManager.events.first(where: {$0.type.rawValue == id && $0.startDate > Date()})
            color = targetEvent?.calendarColor ?? .blue
            bottomText = id
            
        }
    }
}
