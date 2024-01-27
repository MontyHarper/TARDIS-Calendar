//
//  ButtonMaker.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 1/24/24.
//

import Foundation
import SwiftUI

class ButtonMaker: ObservableObject {
    
    var eventManager: EventManager!
    
    @Published var buttons = [ButtonModel]()
    var refreshDate = Timeline.maxDay
    
    
    func updateButtons() {
    
        buttons = []
        refreshDate = Timeline.maxDay
        
        // Make a next event button
        var button = ButtonModel(eventManager: eventManager, id: "first")
        buttons.append(button)
        
        // Make a button for each relevant calendar type
        for type in CalendarType.allCases {
            
            switch type {
            case .banner, .none:
                print("no button for type: ", type)
                
            default:
                if eventManager.events.first(where: {$0.type == type.rawValue && $0.startDate > Date()}) != nil {
                    let button = ButtonModel(eventManager: eventManager, id: type.rawValue)
                    buttons.append(button)
                }
                
                if let lastEvent = eventManager.events.last(where: {$0.type == type.rawValue && $0.startDate > Date()}) {
                    refreshDate = (lastEvent.startDate < refreshDate) ? lastEvent.startDate : refreshDate
                }
            }
        } // End of calendar type buttons.
        
        // Make a button to span the whole timeline.
        button = ButtonModel(eventManager: eventManager, id: "all")
        buttons.append(button)
    }
}
