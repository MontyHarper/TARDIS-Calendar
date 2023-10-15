//
//  SolarDay.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 10/7/23.
//

import CoreLocation
import Foundation

struct Results:Codable {
    let results: [SolarDay]
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
    let date: Date
    let latitude: Double
    let longitude: Double
}
