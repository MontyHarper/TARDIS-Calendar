//
//  SolarEventManager.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 2/13/24.
//
//  This Class keeps an up-to-date array of solar days, from which the app creates a background view representing sunrise and sunset with color gradients.
//

import CoreLocation
import SwiftUI


class SolarEventManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    
    // MARK: - Published Properties
    
    @Published var solarDays = [SolarDay]() {
        
        didSet {
            
            // Keeping a backup in UserDefaults to use in case API is unavailable.
            saveSolarDaysBackup()
            
            // Setting a timer to update solar days again tomorrow.
            var secondsToTimer: Double
            // Preferable to use the calendar; a change could happen mid-day if the user's location changes.
            let tomorrow: Date? = Timeline.calendar.date(byAdding: .day, value: 1, to: Date())
            // Calendar doesn't know if there will be a tomorrow!
            if let tomorrow = tomorrow {
                let timerDate = Timeline.calendar.startOfDay(for: tomorrow)
                secondsToTimer = timerDate.timeIntervalSince1970 - Date().timeIntervalSince1970
            } else {
                // If there's no tomorrow, update again in 24 hours anyway.
                secondsToTimer = 24*60*60
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + secondsToTimer) {
                self.updateSolarDays()
            }
        }
    }
    
    // MARK: - Private Properties
    
    @EnvironmentObject private var stateBools: StateBools
    
    private let locationManager = CLLocationManager()
    private let networkManager = NetworkManager()
    
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
        
        // Note that solarDays will be updated by the locationManager as soon as it gets initialize.
        locationManager.delegate = self
        // This authorization request should happen only once, when the app is first launched.
        locationManager.requestWhenInUseAuthorization()
        // The following requests a location to start off with, which will be processed through the didUpdateLocation method below.
        // SignificantLocationChange means 500 meters or more.
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    // Necessary to keep the app from launching if location changes while app is inactive.
    deinit {
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    // MARK: - Methods for Updating
    
    func updateSolarDays() {
        
        var newSolarDays = solarDays
        
        // Required date range.
        let minDay = Timeline.minDay
        let maxDay = Timeline.maxDay
        
        // We need the user's location in order to retrieve solar days from the API.
        guard stateBools.authorizedForLocationAccess else {
            // If we are not authorized, use stored solarDays to approximate a backdrop.
            fetchSolarDaysFromBackup(minDay: minDay, maxDay: maxDay)
            return
        }
        
        // Remove any SolarDays that are no longer valid.
        if stateBools.locationChangeAwaitingUpdate {
            newSolarDays = [] // Change of location invalidates all the days.
            stateBools.locationChangeAwaitingUpdate = false
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
                
        // Recursive function to fetch days in order
        func fetchNext(day: Date, closure: () -> Void) {
            networkManager.fetchSolarDay(longitude: longitude, latitude: latitude, formattedDate: formatter.string(from: dayZero)) { solarDay in
                if let solarDay = solarDay {
                    newSolarDays.append(solarDay)
                    if day < maxDay {
                        let nextDay = Timeline.calendar.date(byAdding: .day, value: 1, to: day)!
                        fetchNext(day: nextDay) {}
                    } else {
                        return
                    }
                } else {
                    // bad network call
                    self.fetchSolarDaysFromBackup(minDay: minDay)
                }
            }
        } // End of fetchNext(day:)
        
        // Trigger recursive functon and store the results
        fetchNext(day: dayZero) {
            solarDays = newSolarDays
        }
        
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
        stateBools.locationChangeAwaitingUpdate = true
        
        updateSolarDays()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {

        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            stateBools.authorizedForLocationAccess = true
        default:
            stateBools.authorizedForLocationAccess = false
        }
        print("Location Authorization Changed: \(manager.authorizationStatus)")

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        // TODO: - handle possible errors
        print("location manager failed with error: \(error)")
    }
}
