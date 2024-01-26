//
//  BannerMaker.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 1/24/24.
//

import EventKit
import Foundation
import SwiftUI

class BannerMaker {
    
    var banners = [EKEvent]()
    var bannerText = ""
    var refreshDate = Timeline.maxDay
    var marquee = MarqueeController("", fontSize: 24)
    let eventStore = EventStore.shared.store
    
    var eventManager: EventManager!
    
    func updateBanners() {
        
        bannerText = ""
        refreshDate = Timeline.maxDay
        
        // Set up date parameters
        let start = Timeline.minDay
        let end = Timeline.maxDay
        
        // Search for events in selected calendars that are banner type
        let calendarsToSearch = eventManager.appleCalendars.filter({$0.isSelected && $0.type == "banner"}).map({$0.calendar})
        
        // Set up search predicate
        let findEKEvents = eventStore.predicateForEvents(withStart: start, end: end, calendars: calendarsToSearch)
                
        // Store the search results, converting EKEvents to Events.
        banners = eventStore.events(matching: findEKEvents)
        
        for banner in banners {
            if banner.startDate < Date() && banner.endDate > Date() {
                bannerText += banner.title + "  ★  "
            }
            if banner.startDate > Date() && banner.startDate < refreshDate {
                refreshDate = banner.startDate
            }
            if banner.endDate > Date() && banner.endDate < refreshDate {
                refreshDate = banner.endDate
            }
        } // End of loop
        
        print("new banner text: ", bannerText, "\nrefresh date: ", refreshDate.formatted())
        
        marquee = MarqueeController(bannerText, fontSize: 24 )
    }
}
