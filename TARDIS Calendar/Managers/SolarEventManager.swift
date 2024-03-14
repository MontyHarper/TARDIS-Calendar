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

// Combines data from solarDay into a single array of screen stops representing sunrise, sunset, and other solar events.
class SolarEventManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    
    // MARK: - Published / Public Properties
    
    // This is the background gradient representing day and night.
    @Published var screenStops: [Gradient.Stop] = [Gradient.Stop(color: Color.noon, location: 0.0)]
    
    var solarDays = [SolarDay]() {
        didSet {
            // Keeping a backup in UserDefaults to use in case API is unavailable.
            saveSolarDaysBackup()
        }
    }
    
    // Starting with an approximation of the size of the gradient.
    var gradientStart: Double = Date().timeIntervalSince1970 - 24 * 60 * 60
    var gradientSpan: Double = 24 * 60 * 60 * 7
    
    // MARK: - Private Properties
    
    private var updateWhenCurrentDayChanges: AnyCancellable?
    private var stateBools = StateBools.shared
    private let locationManager = CLLocationManager()
    private let networkManager = NetworkManager()
    private var newSolarDays = [SolarDay]()
    private var internetConnection: AnyCancellable?
        
    private var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    private var longitude: Double {
        UserDefaults.standard.double(forKey: UserDefaultKey.Longitude.rawValue)
    }
        
    private var latitude: Double {
        UserDefaults.standard.double(forKey: UserDefaultKey.Latitude.rawValue)
    }
    
    // MARK: - init and deinit
    
    override init() {
        super.init()
                
        // Set default values for user location, in case authorization is denied.
        UserDefaults.standard.set(-97.058570, forKey: UserDefaultKey.Longitude.rawValue)
        UserDefaults.standard.set(36.110170, forKey: UserDefaultKey.Latitude.rawValue)
        
        locationManager.delegate = self
        // This authorization request should happen only once, when the app is first launched.
        locationManager.requestWhenInUseAuthorization()
        // The following requests a location to start off with, which will be processed through the didUpdateLocation method below.
        // SignificantLocationChange means 500 meters or more.
        locationManager.startMonitoringSignificantLocationChanges()

        // This notification will update solarDays if the internet connection is lost and returns.
        internetConnection = NetworkMonitor().objectWillChange.sink {_ in
            print("internet connection has changed")
            if !self.stateBools.internetIsDown {
                self.updateSolarDays()
            }
        }
        
        // This notification will update solarDays when the date changes.
        let dayTracker = DayTracker()
        updateWhenCurrentDayChanges = dayTracker.$today.sink { _ in
            self.updateSolarDays()
        }
        
        // Initial update of solar days is not needed here; an update is called when the app becomes active.
        
    } // End of init
    
    // Necessary to keep the app from launching if location changes while app is inactive.
    deinit {
        locationManager.stopMonitoringSignificantLocationChanges()
        updateWhenCurrentDayChanges?.cancel()
        internetConnection?.cancel()
    }
    
    // MARK: - Methods for Updating
    
    func updateSolarDays(all: Bool = false) {
        
        // This function may be triggered from multiple locations; locking it prevents data races. I'm sure there's a more elegant way to do this, but I don't know it yet!
        guard !stateBools.solarDaysUpdateLocked else {
            stateBools.solarDaysUpdateWaiting = true
            // A single request for all should trigger the next update to update all.
            if all {stateBools.solarDaysUpdateWaitingAll = true}
            return
        }
        
        stateBools.solarDaysUpdateLocked = true
                
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
        
        // Figure out which days need to be added: from DayZero (next day after the ones we already have) to maxDay (latest day to be shown on the calendar).
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
        
        // If there are no days to update, return without doing anything.
        guard dayZero <= maxDay else {return}
        
        
        // Trigger recursive functon and store the results
        fetchNext(day: dayZero) {
            
            // This closure executes once all the solarDays are updated
            UserDefaults.standard.set(Date(), forKey: UserDefaultKey.LastSolarDayDownloaded.rawValue)
            
            self.solarDays = self.newSolarDays
            
            // Update the background gradient, which is based on SolarDays.
            self.updateScreenStops() {
                
                // Unlock updateSolarDays after ScreenStops have also been updated.
                self.stateBools.solarDaysUpdateLocked = false
                if self.stateBools.solarDaysUpdateWaiting {
                    self.updateSolarDays(all: self.stateBools.solarDaysUpdateWaitingAll)
                }
                return
            }
        }
                
        // Recursive function to fetch days in order
        func fetchNext(day: Date, closure: @escaping () -> Void) {
        
            networkManager.fetchSolarDay(longitude: longitude, latitude: latitude, formattedDate: formatter.string(from: dayZero)) { solarDay in
                if let solarDay = solarDay {
                    self.newSolarDays.append(solarDay)
                    if day < maxDay {
                        let nextDay = Timeline.calendar.date(byAdding: .day, value: 1, to: day)!
                        fetchNext(day: nextDay, closure: closure)
                    } else {
                        closure()
                        return
                    }
                } else {
                    // bad network call
                    print("Tried to fetch day but ran into an error.")
                    self.fetchSolarDaysFromBackup(minDay: minDay)
                }
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
        // TODO: - Initially I used CoreData, because that was a requirement for the assignment. But UserDefaults is simpler. If this works fine, I can remove the CoreData stuff.
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
        
        updateSolarDays(all: true)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {

        let status = manager.authorizationStatus
        
        print("Location Authorization Changed: \(status)")
        
        let access = (status == .authorizedAlways || status == .authorizedWhenInUse)
        UserDefaults.standard.set(access, forKey: UserDefaultKey.AuthorizedForLocationAccess.rawValue)
        
        updateSolarDays()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        // TODO: - handle possible errors
        print("location manager failed with error: \(error.localizedDescription)")
    }
    
    
    // Called each time solarDays gets updated; generates a gradient for the background view
    func updateScreenStops(closure: () -> Void) {
        
        // If solarDays are empty, return the default of a single color.
        guard !solarDays.isEmpty else {
            print("Trying to generate screen stops but solarDays is empty: ", Date())
            DispatchQueue.main.async {
                self.screenStops = [Gradient.Stop(color: Color.noon, location: 0.0)]
            }
            closure()
            return
        }
        
        var newStops = [Gradient.Stop]()
        
        // Calculate distance between last event and first event in the gradient
        let first = solarDays[0].firstLightTime
        let last = solarDays[solarDays.count - 1].lastLightTime
        let span = last - first
        
        for day in solarDays {
            
            print("Stops for: ", day.dateDate.formatted())
            
            let solarEvents = day.colorsAndTimes
            
            for i in 0 ..< solarEvents.count {
                
                let event = solarEvents[i]
                let color = event.0
                let location = (event.1 - first) / span // Location of stop in unit space
                
                newStops.append(.init(color: color, location: location))
                print("add stop: ", newStops[newStops.count - 1])
                
            } // end of events loop
                        
        } // End of days loop
        
        DispatchQueue.main.async {
            self.screenStops = newStops
            // Make gradient size available for BackgroundView calculations.
            self.gradientStart = first
            self.gradientSpan = span
            self.stateBools.showProgressView = false
        }
        
        closure()
        
    } // End of updateScreenStops
}
