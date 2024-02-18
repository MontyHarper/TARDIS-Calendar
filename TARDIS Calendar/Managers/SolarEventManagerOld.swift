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

class SolarEventManagerOld: ObservableObject, LocationUpdateReceiver {


    var solarDays: [SolarDay] = []
    var locationManager = LocationManager()
    // Use of CoreData is a requirement for my assignment.
    var dataController = DataController()
    var solarDaysBackupContext: NSManagedObjectContext

    var currentLatitude: Double = 0.0
    var currentLongitude: Double = 0.0

    let stateBools = StateBools.shared
    let defaultLatitude = 36.110170
    let defaultLongitude = -97.058570

    init() {

        // Context for CoreData backup of SolarDays information.
        solarDaysBackupContext = dataController.container.newBackgroundContext()

        // My own delegate protocol; sets SolarEventManager up to receive location updates.
        locationManager.delegate = self

        // This is set here instead of inside updateSolarDays because we only need to show the ProgressView the first time solarDays updates on launch, while the background transitions from nothing to something. If SolarDays updates after that, the download should be invisible to the user, so no need to indicate the app is working behind the scenes.
        stateBools.showProgressView = true

        updateSolarDays() {success in
            self.updateSolarDaysCompletion(success: success)
        }
    }

    func updateSolarDaysCompletion(success: Bool) {
        if success {
            self.stateBools.solarDaysUpdateLocked = false
            self.stateBools.showProgressView = false
            self.stateBools.solarDaysAvailable = true
            self.stateBools.missingSolarDays = 0
            // Save a backup to CoreData
            self.saveBackup()
            // If location has changed, update again.
            if stateBools.locationChangeAwaitingUpdate {
                stateBools.locationChangeAwaitingUpdate = false
                updateSolarDays() {success in
                    self.updateSolarDaysCompletion(success: success)
                }
            }
        } else {
            // Data is unavailable.
            // Attempt to fetch a stored version of solarDays that can be used instead.
            // TODO: - This count will be off if failed updates are due to location change. Instead, store date of last successful update.
            self.stateBools.missingSolarDays += 1
            self.fetchBackup() {success in
                self.stateBools.showProgressView = false
                self.stateBools.solarDaysUpdateLocked = false
                if success {
                    self.stateBools.solarDaysAvailable = true
                } else {
                    self.stateBools.solarDaysAvailable = false
                }
            }
        }
    }

    func receiveLocationUpdate(latitude: Double, longitude: Double) {
        print ("received location update notification")
        UserDefaults.standard.set(longitude,forKey:UserDefaultKey.Longitude.rawValue)
        UserDefaults.standard.set(latitude,forKey:UserDefaultKey.Latitude.rawValue)
        if !stateBools.solarDaysUpdateLocked {
            updateSolarDays(){success in
                self.updateSolarDaysCompletion(success: success)
            }
        } else {
            stateBools.locationChangeAwaitingUpdate = true
        }
    }

    func receiveAuthorizationStatusChange(authorized: Bool) {
        StateBools.shared.authorizedForLocationAccess = authorized
    }

    // MARK: - Update Solar Days
    // This method fetches solar event data for the max number of days possibly shown onscreen.
    // This is called...
    // - once from init
    // - whenever locationManager detects a change in location
    // - once per day from ContentView
    func updateSolarDays(_ result: @escaping (Bool) -> Void) {

        stateBools.solarDaysUpdateLocked = true // To avoid running this function twice concurrently; also displays ProgressView while updating.


        // MARK: - Retrieve location.
        // First try the location manager's current location; if that fails try location saved in user defaults; if that fails, use default location.

        if let latitude = locationManager.currentLatitude, let longitude = locationManager.currentLongitude {

            currentLatitude = latitude
            currentLongitude = longitude

        } else if let latitude = UserDefaults.standard.object(forKey: UserDefaultKey.Latitude.rawValue) as? Double, let longitude = UserDefaults.standard.object(forKey: UserDefaultKey.Longitude.rawValue) as? Double {

            currentLatitude = latitude
            currentLongitude = longitude

        } else {

            currentLatitude = defaultLatitude
            currentLongitude = defaultLongitude
        }

        print("update solar days was called")

        // Reset the array to empty.
        solarDays = []

        // Set up a range of dates
        let startDate = Timeline.minDay // Start of day
        let endDate = Timeline.maxDay // Start of day
        let date = startDate

        print("lon \(currentLongitude), lat \(currentLatitude)")

        fetchSolarDay(date: date, endDate: endDate, result: result)
    }


    // MARK: Fetch Solar Day
    // Fetches a single solar day.
    // This function will recursively call itself from its own completion handler.
    // It's set up this way so that the solar days will be added to the array in order i.e. for thread safety.
    // TODO: - I think this can also be done with an async sequence? But I haven't figured that bit of magic out yet. Maybe for a future re-factor. For now, this seems to be working great.

    func fetchSolarDay(date: Date, endDate: Date, result: @escaping (Bool) -> Void) {

        print("fetching a solar day for \(date)")

        // set up the fetch
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let formattedDate = formatter.string(from: date)

        // TODO: - factor out url into a separate object, in case we ever need to change the source API
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

                print("Data: ", String(data: data, encoding: .utf8) as Any)
                // Add results to the array of solar events.
                let decoder = JSONDecoder()
                do {
                    let results = try decoder.decode(Results.self, from: data)
                    let solarDay = results.results
                    self.solarDays.append(solarDay)

                } catch {
                    // This shouldn't happen unless the api changes on me.
                    print("The data doesn't fit our response pattern")
                }

                // Advance the date; if we have more dates, call for the next one...
                print("Current Date: ", date.formatted())
                let nextDate = Timeline.calendar.date(byAdding: .day, value: 1, to: date) ?? Date(timeIntervalSince1970: (date.timeIntervalSince1970 + Double(60 * 60 * 24)))
                print("Next Date: ", nextDate.formatted())
                if nextDate <= endDate {
                    self.fetchSolarDay(date: nextDate, endDate: endDate, result: result)
                } else {
                    // We have a complete set of solarDays to work with!
                    result(true)
                }
            } else {
                // No data
                result(false)
            }
        }
        task.resume()

    } // End of fetchSolarDay()

    // MARK: - ScreenStops
    // This method returns an array of stops that matches the timeline currently showing on screen. The leading time and trailing time are each matched to an interpolated color, allowing the user to zoom smoothly without colors jumping around at the edge of the screen.
    func screenStops(timeline: Timeline) -> [Gradient.Stop] {

        guard stateBools.solarDaysAvailable else {
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
            guard let index = solarDays.firstIndex(where: {$0.dateDate == day}) else {
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
                    if let index = solarDays.firstIndex(where: {$0.dateDate == nextDay}) {
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

    // MARK: - Interpolate
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


    // MARK: - Fetch Backup
    // This function fetches a backup array of solar days stored in CoreData, in case needed.
    func fetchBackup(success: (Bool) -> Void ) {

        print("fetching backup solar days")

        var solarDaysBackup: [StoredSolarDay] = []

        let fetchRequest: NSFetchRequest<StoredSolarDay> = StoredSolarDay.fetchRequest()
        do {
            solarDaysBackup = try solarDaysBackupContext.fetch(fetchRequest)
        } catch {
            print("error fetching backup")
            success(false)
            return
        }

        var proposedSolarDays = solarDaysBackup.map({SolarDay(day: $0)}).sorted(by: {$0.dateDate < $1.dateDate})

        print("solar days backed up: \(proposedSolarDays)")

        // If there are no results, abort the attempt. No solar days are available.
        if proposedSolarDays.isEmpty {
            success(false)
            return

        }

        // Hold on to the last solar day available.
        let lastDay = proposedSolarDays[proposedSolarDays.count - 1]

        // Remove days earlier than our starting date.
        proposedSolarDays = proposedSolarDays.filter({$0.dateDate >= Timeline.minDay})

        // Add missing days by repeating data from the last available solar day.
        // Find the latest stored date.
        let lastAvailableDate = proposedSolarDays[proposedSolarDays.count - 1].dateDate

        // Start with the later of that date or the min date required, and add a solar day for each day from there to the max date required.
        let df = DateFormatter()
        df.dateFormat = "YYYY-MM-dd"
        var date = Timeline.minDay <= lastAvailableDate ? lastAvailableDate : Timeline.minDay
        var tagOnDays: [SolarDay] = []
        while date <= Timeline.maxDay {
            tagOnDays.append(lastDay)
            date = Timeline.calendar.date(byAdding: .day, value: 1, to: date)!
        }

        solarDays = proposedSolarDays + tagOnDays
        print("backup solar days = \(solarDays)")

        success(true)
        return
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
            saveTheDay.date = day.date

            do {
                try solarDaysBackupContext.save()
            } catch {
                print("unable to save")
            }
        }
    }
}


