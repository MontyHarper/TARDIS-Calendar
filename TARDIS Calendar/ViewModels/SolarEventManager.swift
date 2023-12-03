//
//  SolarEvents.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 10/12/23.
//
//  Downloads solar events (sunrise, sunset, etc.) from sunrisesunset api.
//  Based on that data, the screenstops function provides an array of gradient stops,
//  which serves as a background to the calendar, representing day and night as colors
//  spread across the screen.
//  Persists data using CoreData, and defaults to using CoreData when the api is not available.
//

import CoreData
import CoreLocation
import Foundation
import Network
import SwiftUI

class SolarEventManager: LocationManagerDelegate, ObservableObject {
    
    var solarDays: [SolarDay] = []
    var currentLatitude = 36.110170
    var currentLongitude = -97.058570 // Will give these values when needed.
    // Use of CoreData is a requirement for my assignment.
    var dataController = DataController()
    var solarDaysBackupContext: NSManagedObjectContext
    let stateBools = StateBools.shared
    
    // User's location is needed for the sunrisesunset api to return accurate times.
    // TODO: - handle the case where user does not give permission
    
    private var locationManager = CLLocationManager()

    override init() {
        
        // Context for CoreData backup of SolarDays information.
        solarDaysBackupContext = dataController.container.newBackgroundContext()
        super.init()
        
        // Set up location tracking; user location is required to fetch accurate SolarDays information.
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        
        // Fetch fresh SolarDays information.
        stateBools.showLoadingBackground = true
        // TODO: - The update method can probably be streamlined to take better advantage of network connection awareness and CoreData persistence.
        updateSolarDays()
    }
    
    deinit {
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    override func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            stateBools.noPermissionForLocation = false
            if stateBools.solarDaysAvailable {updateSolarDays()}
        default:
            stateBools.noPermissionForLocation = true
        }
        print("Authorization Changed: \(manager.authorizationStatus)")
    }
    
    // If location changes, save the new location in UserDefaults.
    override func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("update location is called")
        let newLocation = locations[locations.count - 1]
        let longitude = newLocation.coordinate.longitude
        let latitude = newLocation.coordinate.latitude
        print("new location: lon \(longitude), lat \(latitude)")
        UserDefaults.standard.set(longitude,forKey:"longitude")
        UserDefaults.standard.set(latitude,forKey:"latitude")
        if stateBools.solarDaysAvailable {updateSolarDays()}
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location manager failed with error: \(error)")
    }
    
    // This method fetches solar event data for the max number of days possibly shown onscreen.
    // This is called...
    // - once from init
    // - whenever locationManager detects a change in location
    // - once per day from ContentView
    // TODO: - call this function whenever internet connection is restored
    func updateSolarDays() {
        
        solarDaysAvailable = false // To avoid running this process more than once concurrently.
        
        print("update solar days was called")
        
        // Reset the array to empty.
        solarDays = []
        
        // Set up a range of dates
        let startDate = Timeline.minDay
        let endDate = Timeline.maxDay
        let date = startDate
        currentLongitude = UserDefaults.standard.double(forKey:"longitude")
        currentLatitude = UserDefaults.standard.double(forKey:"latitude")
        print("lon \(currentLongitude), lat \(currentLatitude)")

        // This function will recursively call itself from its own completion handler.
        // It's set up this way so that the solar days will be added to the array in order i.e. for thread safety.
        // TODO: - I think this can also be done with an async sequence? But I haven't figured that bit of magic out yet. Maybe for a future re-factor. For now, this seems to be working great.
        
        fetchSolarDay(date: date, endDate: endDate)
    }
    
    
    func fetchSolarDay(date: Date, endDate: Date) {
        
        print("fetching a solar day for \(date)")
        
        // set up the fetch
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let formattedDate = formatter.string(from: date)
        let urlString = "https://api.sunrisesunset.io/json?lat=" + String(currentLatitude) + "&lng=" + String(currentLongitude) + "&date=" + formattedDate
        guard let url = URL(string: urlString) else {
            // This should never happen; the urlString is a valid URL
            print("unable to form a URL for fetching solar day \(formattedDate)")
            return }
        let request = URLRequest(url: url)
        let session = URLSession.shared
        
        // fetch
        let task = session.dataTask(with: request) { data, response, error in
            
            // If data is returned,
            if let data = data {
                
                // Insert the date into the data so that each solarDay can have an associated date.
                var dataString = String(decoding: data, as: UTF8.self)
                let index = dataString.firstIndex(of: "}")!
                dataString.insert(contentsOf: ",\"dateString\":\"\(formattedDate)\"", at: index)
                let newData = Data(dataString.utf8)
                // Print statement to use for debugging purposes; seems to be working well now.
                // print(String(decoding: newData, as: UTF8.self))
                
                // Add results to the array of solar events.
                let decoder = JSONDecoder()
                do {
                    let results = try decoder.decode(Results.self, from: newData)
                    let solarDay = results.results
                    self.solarDays.append(solarDay)
                    
                } catch {
                    // This shouldn't happen unless the api changes on me.
                    print("The data doesn't fit our response pattern")
                }
                
                // Advance the date; if we have more dates, call for the next one...
                let nextDate = Timeline.calendar.date(byAdding: .day, value: 1, to: date) ?? Date(timeIntervalSince1970: (date.timeIntervalSince1970 + Double(60 * 60 * 24)))
                if nextDate <= endDate {
                    self.fetchSolarDay(date: nextDate, endDate: endDate)
                } else {
                    // We have a complete set of solarDays to work with!
                    self.solarDaysAvailable = true
                    self.stateBools.missingSolarDays = 0
                    self.stateBools.showLoadingBackground = false
                    // Save a backup to CoreData
                    self.saveBackup()
                }
            } else {
                // Assume no data indicates a bad internet connection
                // This process is not continued, and solarDaysAvailable remains false.
                // Attempt to fetch a stored version of solarDays that can be used instead.
                self.stateBools.missingSolarDays += 1
                self.fetchBackup()
            }
        }
        task.resume()
                
    } // End of fetchSolarDay()
    
        
    // This method returns an array of stops that matches the timeline currently showing on screen. The leading time and trailing time are each matched to an interpolated color, allowing the user to zoom smoothly without colors jumping around at the edge of the screen.
    func screenStops(timeline: Timeline) -> [Gradient.Stop] {
                
        guard solarDaysAvailable else {
            print("solar days unavailable")
            return [Gradient.Stop(color: Color.noon, location: 0.0)]
        }
                
        // Set up initial values
        let leadingDate = timeline.leadingDate
        let leadingTime = timeline.leadingTime
        let trailingDate = timeline.trailingDate
        let trailingTime = timeline.trailingTime
        let calendar = Timeline.calendar
        
        // Array of stops to return
        var screenStops: [Gradient.Stop] = []
        
        // Begin with the first day
        var day: Date = calendar.startOfDay(for:leadingDate)
        let lastDay: Date = calendar.startOfDay(for:trailingDate)
        
        // Iterate until the last day
        dayLoop: while day <= lastDay {
            
            // Find this day's solar events. If they dont exist, exit the loop
            guard let index = solarDays.firstIndex(where: {$0.date == day}) else {
                break dayLoop
            }
            let solarEvents = solarDays[index].colorsAndTimes
            let nextDay = calendar.date(byAdding: .day, value: 1, to: day)!
            
            // Iterate over stops in the current day.
            stopLoop: for i in 0 ..< solarEvents.count {
                
                let event = solarEvents[i]
                
                // Find the event for the next stop; go to the next day if needed
                var nextEvent: (Color, Double)
                if i + 1 == solarEvents.count {
                    if let index = solarDays.firstIndex(where: {$0.date == nextDay}) {
                        nextEvent = solarDays[index].colorsAndTimes[0]
                    } else {
                        // If we've run out of events (shouldn't happen), just use the current event again.
                        nextEvent = event
                    }
                } else { // Grab the next event in the current solar day.
                    nextEvent = solarEvents[i + 1]
                }
                
                // Now we have times in seconds for the current event and the next event.
                let stopTime = event.1
                let nextStopTime = nextEvent.1
                
                // We need to create a screenStop for this event, if the event is "onscreen."
                // If we are at either edge of the screen, the color for the stop needs to be interpolated.
                
                // First, check if the entire screen lies between this event and the next event. If so, interpolate both endpoints.
                if stopTime <= leadingTime && nextStopTime >= trailingTime {
                    
                    let leadingStopColor = interpolate(event, nextEvent, to: leadingTime)
                    let trailingStopColor = interpolate(event, nextEvent, to: trailingTime)
                    screenStops.append(.init(color: leadingStopColor, location: 0.0))
                    screenStops.append(.init(color: trailingStopColor, location: 1.0))
                    break dayLoop // We've added the final stop
                }
                    
                // Next, check if this event is the first event shown onscreen; if so interpolate the first endpoint.
                if stopTime <= leadingTime && nextStopTime >= leadingTime {
                    
                    let leadingStopColor = interpolate(event, nextEvent, to: leadingTime)
                    screenStops.append(.init(color: leadingStopColor, location: 0.0))
                    
                }
                
                // Next, check if both this event and the next event are shown onscreen; if so, no interpolation is needed.
                if stopTime >= leadingTime && nextStopTime <= trailingTime {
                    
                    // Add screenStop for event, converting timespace to unitspace.
                    screenStops.append(.init(color: event.0, location: timeline.unitX(fromTime: event.1)))
                }
                    
                // Next check if this is the last event located onscreen.
                if stopTime <= trailingTime && nextStopTime >= trailingTime {
                    
                    // If so, we need to create two screenStops, one for the current event, and one at the trailing edge of the screen, interpolated between the current and next event.
                    
                    screenStops.append(.init(color: event.0, location: timeline.unitX(fromTime: event.1)))
                    let trailingStopColor = interpolate(event, nextEvent, to: trailingTime)
                    screenStops.append(.init(color: trailingStopColor, location: 1.0))
                    
                    break dayLoop // exit loop; we have added the final stop
                }
                
            }
            // end of stops loop
        
            day = nextDay
        
        } // end of dayLoop
        
        return screenStops
        
    } // end of screenStops function
    
    // This function returns a new color, interpolated to match a new time between two given stops.
    func interpolate(_ stop1: (Color, Double), _ stop2: (Color, Double), to newTime: Double) -> Color {
        
        let color1 = stop1.0
        let color2 = stop2.0
        let time1 = stop1.1
        let time2 = stop2.1
    
        let percent = (newTime - time1)/(time2 - time1)
        
        let a = color1.parts().hue; let b = color1.parts().saturation; let c = color1.parts().brightness
        let x = color2.parts().hue; let y = color2.parts().saturation; let z = color2.parts().brightness
        
        let newColor = Color(hue: a + (x-a)*percent, saturation: b + (y-b)*percent, brightness: c + (z-c)*percent)
        
        return newColor
    }
    
    
    func fetchBackup() {
        
        print("fetching backup solar days")
        
        var solarDaysBackup: [StoredSolarDay] = []
        
        let fetchRequest: NSFetchRequest<StoredSolarDay> = StoredSolarDay.fetchRequest()
        do {
            solarDaysBackup = try solarDaysBackupContext.fetch(fetchRequest)
        } catch {
            print("error fetching backup")
            return
        }

        var proposedSolarDays = solarDaysBackup.map({SolarDay(day: $0)}).sorted(by: {$0.date < $1.date})
        
        print("solar days backed up: \(proposedSolarDays)")
        
        // If there are no results, abort the attempt. No solar days are available.
        if proposedSolarDays.isEmpty { return }
        
        // Hold on to the last solar day available.
        var lastDay = proposedSolarDays[proposedSolarDays.count - 1]
        
        // Remove days earlier than our starting date.
        proposedSolarDays = proposedSolarDays.filter({$0.date >= Timeline.minDay})
        
        // Add missing days by repeating data from the last available solar day.
        // Find the latest stored date.
        let lastAvailableDate = proposedSolarDays[proposedSolarDays.count - 1].date
        
        // Start with the later of that date or the min date required, and add a solar day for each day from there to the max date required.
        let df = DateFormatter()
        df.dateFormat = "YYYY-MM-dd"
        var date = Timeline.minDay <= lastAvailableDate ? lastAvailableDate : Timeline.minDay
        var tagOnDays: [SolarDay] = []
        while date <= Timeline.maxDay {
            lastDay.dateString = df.string(from: date)
            tagOnDays.append(lastDay)
            date = Timeline.calendar.date(byAdding: .day, value: 1, to: date)!
        }
    
        solarDays = proposedSolarDays + tagOnDays
        print("backup solar days = \(solarDays)")
        solarDaysAvailable = true
    }
    
    func saveBackup() {
        let fetchRequest: NSFetchRequest<StoredSolarDay> = StoredSolarDay.fetchRequest()
        
        // Delete existing backup
        do {
            let daysToDelete = try solarDaysBackupContext.fetch(fetchRequest)
            
            for day in daysToDelete {
                solarDaysBackupContext.delete(day)
            }
            try solarDaysBackupContext.save()
        } catch {
            print("Error deleting objects")
        }
        
        // Save new backup
        for day in solarDays {
            let saveTheDay = StoredSolarDay(context: solarDaysBackupContext)
            saveTheDay.sunrise = day.sunrise
            saveTheDay.sunset = day.sunset
            saveTheDay.first_light = day.first_light
            saveTheDay.last_light = day.last_light
            saveTheDay.dawn = day.dawn
            saveTheDay.dusk = day.dusk
            saveTheDay.solar_noon = day.solar_noon
            saveTheDay.golden_hour = day.golden_hour
            saveTheDay.day_length = day.day_length
            saveTheDay.timezone = day.timezone
            saveTheDay.utc_offset = Int16(exactly: day.utc_offset) ?? 0
            saveTheDay.dateString = day.dateString
            
            do {
                try solarDaysBackupContext.save()
            } catch {
                print("unable to save")
            }
        }
    }
}


