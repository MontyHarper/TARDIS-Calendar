//
//  SolarEventManager.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 2/13/24.
//
//  This Class keeps an up-to-date array of solar days, from which the app creates a background view representing sunrise and sunset with color gradients.
//

import Foundation


class SolarEventManager {
    
    var solarDays = [SolarDay]() {
        didSet {
            saveSolarDaysBackup()
            // set timer to update solar days when day changes
        }
    }
    
    private let locationManager = LocationManager()
    private let networkManager = NetworkManager()
    
    init() {
        updateSolarDays()
        // Set up LocationManager to update days as needed
    }
    
    func updateSolarDays() {
        
        // Get min and max days
        // Get longitude and latitude
        // Remove expired days from the array
        // Determine which days actually need fetching
        // Recursively fetch the days
        // Or Fetch days from backup as needed
    }
    
    func fetchSolarDaysFromBackup(minDay: Date, maxDay: Date) {
        // Fetch days from UserDefaults
        // Use days as needed, repeat days as needed
    }
    
    func saveSolarDaysBackup() {
        // Save days to UserDefaults
    }
}
