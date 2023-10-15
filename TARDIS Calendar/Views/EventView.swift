//
//  Events.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 8/2/23.
//

import Foundation
import SwiftUI
import EventKit



struct EventView: View {
    
    var startDate: Date
    var endDate: Date
    var title: String
    var size: Double = 25.0
    
    var xLocation: Double = 0.0
    
    init(startDate: Date, endDate: Date, title: String) {
        self.startDate = startDate
        self.endDate = endDate
        self.title = title
    }
    
    var body: some View {
        
        
        Circle()
            .fill(.yellow)
            .frame(width: size, height: size)
            .overlay(
                Text(title).fixedSize().offset(y: -size), alignment: .bottom)
            .overlay(
                Image(systemName: "arrow.right")
                    .offset(x: -size*0.61),
                alignment: .init(horizontal: .center, vertical: .center))
        
    }
}

// This is ViewModel Stuff
    
    struct Events {
        static var onView: [EKEvent] = []
        
        public func loadEvents() {
            
            let store = EKEventStore()
            store.requestAccess(to: EKEntityType.event) {granted, error in
                
                if granted {
                    let calendars = store.calendars(for: .event)
                    let myCalendar = calendars.first(where: { $0.title == "Bena" })!
                    let time = Time(span: Time.maxSpan)
                    let nextTwoWeeks = store.predicateForEvents(withStart: time.leadingDate, end: time.trailingDate, calendars: [myCalendar])
                    Events.onView = store.events(matching: nextTwoWeeks)
                } else {
                    print(error)
                }
            }
            
        }
    }
    
    func eventViewArray(span: Double) -> [EventView] {
        
        let time = Time(span: span)
        var viewsArray = [EventView]()
        
        
        for event in Events.onView {
            
            if (time.leadingDate ... time.trailingDate).contains(event.startDate) {
                
                var view = EventView(startDate: event.startDate, endDate: event.endDate, title: event.title)
                view.xLocation = time.dateToDouble(event.startDate.timeIntervalSince1970)
                
                viewsArray.append(view)
            }
        }
        return viewsArray
    }

