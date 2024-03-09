//
//  ButtonMaker.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 1/24/24.
//

import Foundation
import SwiftUI

class ButtonMaker: ObservableObject {
    
    @Published var buttons = [ButtonModel]()
    
    // Question: does this fix the reference loop?
    weak var eventManager: EventManager?
        
    var refreshDate = TimelineSettings.shared.maxDay()
    
    var timer: Timer?
    
    init() {
        updateButtons()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func updateButtons() {
        
        print("Updating buttons")
        
        buttons = []
        refreshDate = TimelineSettings.shared.maxDay()
        
        guard let eventManager = eventManager else {
            return
        }
        
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
        
        resetTimer(triggerDate: refreshDate)
    }
    
    func resetTimer(triggerDate: Date) {
        
        timer?.invalidate()
        
        let seconds = triggerDate.timeIntervalSince1970 - Date().timeIntervalSince1970
        timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) {_ in
            self.updateButtons()
        }
    }
    
    
}
