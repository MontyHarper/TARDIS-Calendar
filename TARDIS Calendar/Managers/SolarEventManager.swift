//
//  SolarEventManager.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 2/13/24.
//
//  This Class keeps an up-to-date array of solar days, from which the app creates a background view representing sunrise and sunset with color gradients.
//

import Foundation


class SolarEventManager: LocationUpdateReceiver {
    
    
    var solarDays = [SolarDay]() {
        didSet {
            saveSolarDaysBackup()
            // set timer to update solar days when day changes
            var secondsToTimer: Double
            let tomorrow: Date? = Timeline.calendar.date(byAdding: .day, value: 1, to: Date())
            if let tomorrow = tomorrow {
                let timerDate = Timeline.calendar.startOfDay(for: tomorrow)
                secondsToTimer = timerDate.timeIntervalSince1970 - Date().timeIntervalSince1970
            } else {
                secondsToTimer = 24*60*60
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + secondsToTimer) {
                self.updateSolarDays()
            }
        }
    }
    
    private let locationManager = LocationManager()
    private let networkManager = NetworkManager()
    
    init() {
        updateSolarDays()
        // Set up LocationManager to update days as needed
        locationManager.delegate = self
    }
    
    func updateSolarDays() {
        
        // Get min and max days
        // Get longitude and latitude
        // Remove expired days from the array
        // Determine which days actually need fetching
        // Recursively fetch the days
        // Or Fetch days from backup as needed
        
    } // End of updateSolarDays
    
    func fetchSolarDaysFromBackup(minDay: Date, maxDay: Date) {
        // Fetch days from UserDefaults
        // Use days as needed, repeat days as needed
    }
    
    func saveSolarDaysBackup() {
        // Save days to UserDefaults
        if let encoded = try? JSONEncoder().encode(solarDays) {
            UserDefaults.standard.set(encoded, forKey: UserDefaultKey.SolarDaysBackup.rawValue)
        }
    }
    
    func receiveLocationUpdate(latitude: Double, longitude: Double) {
        <#code#>
    }
    
    func receiveAuthorizationStatusChange(authorized: Bool) {
        <#code#>
    }
}
