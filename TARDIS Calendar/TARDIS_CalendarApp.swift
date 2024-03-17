//
//  TARDIS_CalendarApp.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 7/12/23.
//

import EventKit
import SwiftUI

@main
struct TARDIS_CalendarApp: App {
        
    @Environment(\.scenePhase) private var scenePhase
    
    var eventManager = EventManager()
    var solarEventManager = SolarEventManager()
    var labelManager = LabelManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(eventManager)
                .environmentObject(solarEventManager)
                .environmentObject(labelManager)
        }
        .onChange(of: scenePhase) {phase in
            switch phase {
            case .background:
                eventManager.highlightNextEvent()
            case .active:
                print("app is active")
                eventManager.updateEverything()
                solarEventManager.updateSolarDays()
            case .inactive:
                print("app is inactive")
            default:
                print("What is happening? Do apps have a new phase now?")
            }
        }
    }
}
