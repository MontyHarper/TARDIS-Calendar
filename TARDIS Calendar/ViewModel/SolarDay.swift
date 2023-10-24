//
//  SolarDay.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 10/7/23.
//

import CoreLocation
import Foundation

struct Results:Codable {
    let results: SolarDay
    let status: String
}

struct SolarDay: Codable {
    let sunrise: String
    let sunset: String
    let first_light: String
    let last_light: String
    let dawn: String
    let dusk: String
    let solar_noon: String
    let golden_hour: String
    let day_length: String
    let timezone: String
    let utc_offset: Int
}


//    var date: Date = Date()
//    var latitude: Double = 0.0
//    var longitude: Double = 0.0
