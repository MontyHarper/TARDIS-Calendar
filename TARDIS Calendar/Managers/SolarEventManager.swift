//
//  SolarEventManager.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 2/13/24.
//
//  This Class keeps an up-to-date array of solar days, from which the app creates a background view representing sunrise and sunset with color gradients.
//

import Combine
import CoreLocation
import SwiftUI


class SolarEventManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    
    // MARK: - Key Properties
    
    // The backgroundView displays a gradient generated from the following information.
    @Published var screenStops: [Gradient.Stop] = [Gradient.Stop(color: Color.noon, location: 0.0)]
    var gradientStart: Double = Date().timeIntervalSince1970 - 36 * 60 * 60
    var gradientSpan: Double = 24 * 60 * 60 * 10
        
    // The backgroundView information above is based on solarDays, which are downloaded from the sunriseSunset API. The solarDays array is updated in the background on startup, once per day, or whenever we regain an internet connection, or whenever we change location.
    var solarDays = [SolarDay]() {
        didSet {
            print("solarDays has been changed: ", solarDays.map({$0.dateDate.formatted()}))
            // Keep a backup in UserDefaults in case the API is unavailable.
            saveSolarDaysBackup()
            // Update backgroundView information whenever solarDays are updated.
            updateBackground()
        }
    }
    
    // MARK: - Private Properties
    
    // Notifications that can trigger an update.
    private var updateWhenCurrentDayChanges: AnyCancellable?
    private var internetConnection: AnyCancellable?
    private let locationManager = CLLocationManager()
    private let networkManager = NetworkManager()
    
    // Managing updates
    private var newSolarDays = [SolarDay]()
    private var solarDaysUpdateLocked = false 
    private var solarDaysUpdateWaiting = false
    private var solarDaysUpdateWaitingAll = false
    
    // Computed values
    private var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    private var longitude: Double {
        
        if let long = UserDefaults.standard.value(forKey: UserDefaultKey.Longitude.rawValue) as? Double {
            return long
        } else {
            let long = Constants.Defaults.longitude
            UserDefaults.standard.set(long, forKey: UserDefaultKey.Longitude.rawValue)
            return long
        }
    }
        
    private var latitude: Double {
        if let lat = UserDefaults.standard.value(forKey: UserDefaultKey.Latitude.rawValue) as? Double {
            return lat
        } else {
            let lat = Constants.Defaults.latitude
            UserDefaults.standard.set(lat, forKey: UserDefaultKey.Latitude.rawValue)
            return lat
        }
    }
    
    // MARK: - init and deinit
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        // This authorization request should happen only once, when the app is first launched.
        locationManager.requestWhenInUseAuthorization()
        // The following requests a location to start off with, which will be processed through the didUpdateLocation method below.
        // SignificantLocationChange means 500 meters or more.
        locationManager.startMonitoringSignificantLocationChanges()

        // This notification will update solarDays if the internet connection is lost and returns.
        internetConnection = NetworkMonitor().objectWillChange.sink {_ in
            print("SolarEventManager says internet connection has changed")
            if NetworkMonitor.internetIsDown == false {
                self.updateSolarDays()
            }
        }
        
        // This notification will update solarDays when the date changes.
        let dayTracker = DayTracker()
        updateWhenCurrentDayChanges = dayTracker.$today.sink { _ in
            print("Date has changed")
            self.updateSolarDays()
        }
        
        // TODO: - verify this
        // Initial update of solar days is not needed here; an update is called when the app becomes active.
        
    } // End of init
    
    // Necessary to keep the app from launching if location changes while app is inactive.
    deinit {
        locationManager.stopMonitoringSignificantLocationChanges()
        updateWhenCurrentDayChanges?.cancel()
        internetConnection?.cancel()
    }
    
    // MARK: - Updating solarDays
    
    func updateSolarDays(all: Bool = false) {
        
        print("updateSolarDays was called")
        // This function may be triggered from multiple locations; locking it prevents data races. I'm sure there's a more elegant way to do this, but I don't know it yet!
        guard !solarDaysUpdateLocked else {
            solarDaysUpdateWaiting = true
            // A single request for all should trigger the next update to update all.
            if all {solarDaysUpdateWaitingAll = true}
            print("updateSolarDays is locked.")
            return
        }
        
        solarDaysUpdateLocked = true
                
        print("updating solar days")
        
        newSolarDays = solarDays
        
        // Required date range.
        let minDay = Timeline.minDay
        let maxDay = Timeline.maxDay
        
        // Remove any SolarDays that are no longer valid.
        if all {
            newSolarDays = [] // Change of location invalidates all the days.
        } else {
            newSolarDays = newSolarDays.filter({$0.dateDate >= minDay}) // Remove outdated days.
        }
        
        // Figure out which days need to be added: from DayZero (next day after the ones we already have) to maxDay (latest day to be shown on screen).
        // Note this depends on many factors including how many days the app may have been inactive before re-awakened.
        var dayZero: Date {
            if let finalDay = newSolarDays.last?.dateDate {
                if let nextDay = Timeline.calendar.date(byAdding: .day, value: 1, to: finalDay) {
                    return nextDay
                } else { // There is no tomorrow; replace all days in a fit of hopeless optimism.
                    return minDay
                }
            } else { // SolarDays is empty; replace all days
                return minDay
            }
        }
        
        
        // Trigger recursive functon and store the results
        fetchNext(day: dayZero) {
            
            // This closure executes once all the solarDays are updated
            UserDefaults.standard.set(Date(), forKey: UserDefaultKey.LastSolarDayDownloaded.rawValue)
            
            self.solarDays = self.newSolarDays
            
            // Unlock updateSolarDays after ScreenStops have also been updated.
            self.solarDaysUpdateLocked = false
            
            if self.solarDaysUpdateWaiting {
                self.solarDaysUpdateWaiting = false
                print("paused update coming through")
                self.updateSolarDays(all: self.solarDaysUpdateWaitingAll)
            }
        }
                
        // Recursive function to fetch days in order
        func fetchNext(day: Date, closure: @escaping () -> Void) {
            if day <= maxDay {
                networkManager.fetchSolarDay(longitude: longitude, latitude: latitude, formattedDate: formatter.string(from: day)) { solarDay in
                    if let solarDay = solarDay {
                        self.newSolarDays.append(solarDay)
                            let nextDay = Timeline.calendar.date(byAdding: .day, value: 1, to: day)!
                            fetchNext(day: nextDay, closure: closure)
                    } else {
                        // bad network call
                        print("Tried to fetch day but ran into an error.")
                        self.fetchSolarDaysFromBackup(minDay: day)
                    }
                }
            } else {
                closure()
                return
            }
        } // End of fetchNext(day:)

    } // End of updateSolarDays
    
    
    func fetchSolarDaysFromBackup(minDay: Date) {
        
        guard let encoded = UserDefaults.standard.object(forKey: UserDefaultKey.SolarDaysBackup.rawValue) else {
            print("Trying to use solarDays backup - none exists.")
            return
        }
            
        guard var newSolarDays = try? JSONDecoder().decode([SolarDay].self, from: encoded as! Data) else {
            print("Trying to use solarDays backup - would not decode.")
            return
        }
            
        guard let fillInSolarDay = newSolarDays.last else {
            print("Trying to use solarDays backup - backup is empty.")
            return
        }
        
        // filter out expired dates
        newSolarDays = newSolarDays.filter({$0.dateDate >= minDay})
                
        // TODO: - each solar day still needs a date in order to calculate the gradient correctly
        // fill in days as needed
        while newSolarDays.count < solarDays.count {
            newSolarDays.append(fillInSolarDay)
        }
        
        solarDays = newSolarDays
        print("Using solarDays backup data.")
    }
    
    func saveSolarDaysBackup() {
        // Save days to UserDefaults.
        if let encoded = try? JSONEncoder().encode(solarDays) {
            UserDefaults.standard.set(encoded, forKey: UserDefaultKey.SolarDaysBackup.rawValue)
        }
    }
    
    // MARK: - Delegate Methods, CLLM
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let newLocation = locations[locations.count - 1]
        let longitude = newLocation.coordinate.longitude
        let latitude = newLocation.coordinate.latitude
        UserDefaults.standard.set(longitude, forKey: UserDefaultKey.Longitude.rawValue)
        UserDefaults.standard.set(latitude, forKey: UserDefaultKey.Latitude.rawValue)
        print("location updated")
        updateSolarDays(all: true)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {

        let status = manager.authorizationStatus
        
        print("Location Authorization Changed: \(status)")
        
        let accessIsGranted = (status == .authorizedAlways || status == .authorizedWhenInUse)
        UserDefaults.standard.set(accessIsGranted, forKey: UserDefaultKey.AuthorizedForLocationAccess.rawValue)
        
        if !accessIsGranted {
            UserDefaults.standard.removeObject(forKey: UserDefaultKey.Latitude.rawValue)
            UserDefaults.standard.removeObject(forKey: UserDefaultKey.Longitude.rawValue)
        }
        
        print("location manager: authorization change")
        updateSolarDays()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        // TODO: - handle possible errors
        print("location manager failed with error: \(error.localizedDescription)")
    }
    
        
    // MARK: - Update Background
    
    // This should be called whenever solarDays gets updated.
    func updateBackground() {
        DispatchQueue.main.async {
            let backgroundGradient = self.backgroundGradient(days: self.solarDays)
            self.screenStops = backgroundGradient.screenStops
            self.gradientStart = backgroundGradient.gradientStart
            self.gradientSpan = backgroundGradient.gradientSpan
        }
    }
    
    // Generates a gradient from an array of SolarDays, along with the starting time and span for the gradient.
    func backgroundGradient(days: [SolarDay]) -> (screenStops: [Gradient.Stop], gradientStart: Double, gradientSpan: Double) {
        
        // If days are empty, return the default of a single color, with approximate start time and span.
        guard !days.isEmpty else {
            print("Generating a default gradient for empty days.")
            return ([Gradient.Stop(color: Color.noon, location: 0.0)], Date().timeIntervalSince1970 - 36 * 60 * 60, 24 * 60 * 60 * 10)
        }
        
        var newStops = [Gradient.Stop]()
        
        // Calculate distance between last event and first event in the gradient
        let first = days[0].firstLightTime
        let last = days[days.count - 1].lastLightTime
        let span = last - first
        
        for day in days {
                        
            let solarEvents = day.colorsAndTimes
            
            for i in 0 ..< solarEvents.count {
                
                let event = solarEvents[i]
                let color = event.0
                let location = (event.1 - first) / span // Location of stop in unit space
                
                newStops.append(.init(color: color, location: location))
                
            } // end of events loop
                        
        } // End of days loop
        
        return (newStops, first, span)
        
    } // End of screenStops
}
