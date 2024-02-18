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
    var timeline = Timeline()
    var stateBools = StateBools()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(eventManager)
                .environmentObject(solarEventManager)
                .environmentObject(timeline)
                .environmentObject(stateBools)
        }
        .onChange(of: scenePhase) {phase in
            switch phase {
            case .background:
                timeline.resetZoom()
            case .active:
                print("app is active")
                // TODO: - check if this is a new day; if so, update solarDays and Events.
            case .inactive:
                print("app is inactive")
            default:
                print("What is happening? Do apps have a new phase now?")
            }
        }
    }
}
