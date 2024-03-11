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
    var marquee: MarqueeViewModel?
    let eventStore = EventStore.shared.store
    var timer: Timer?
    
    weak var eventManager: EventManager?
        
    init() {
        updateBanners()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func updateBanners() {
        
        print("Updating Banners")
        
        bannerText = ""
        var newRefreshDate = Timeline.maxDay
        
        guard let eventManager = eventManager else {
            return
        }
        
        // Set up date parameters
        let start = Timeline.minDay
        let end = Timeline.maxDay
        
        // Search for events in selected calendars that are banner type
        let calendarsToSearch = eventManager.appleCalendars.filter({$0.isSelected && $0.type == CalendarType.banner.rawValue}).map({$0.calendar})
        
        if calendarsToSearch.isEmpty {
            
            bannerText = ""
            marquee = nil
            
        } else {
            
            // Set up search predicate
            let findEKEvents = eventStore.predicateForEvents(withStart: start, end: end, calendars: calendarsToSearch)
            
            // Store the search results
            banners = eventStore.events(matching: findEKEvents)
            
            for banner in banners {
                if banner.startDate < Date() && banner.endDate > Date() {
                    bannerText += banner.title + "  ★  "
                }
                if banner.startDate > Date() && banner.startDate < newRefreshDate {
                    newRefreshDate = banner.startDate
                }
                if banner.endDate > Date() && banner.endDate < newRefreshDate {
                    newRefreshDate = banner.endDate
                }
            } // End of loop
            
            refreshDate = newRefreshDate
            
            marquee = MarqueeViewModel(bannerText, fontSize: 24 )
            
            resetTimer(triggerDate: refreshDate)
        }
    }
    
    func resetTimer(triggerDate: Date) {
        
        timer?.invalidate()
        
        let seconds = triggerDate.timeIntervalSince1970 - Date().timeIntervalSince1970
        timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) {_ in
            self.updateBanners()
        }
    }
}
