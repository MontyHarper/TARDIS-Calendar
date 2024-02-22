//
//  SolarDay.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 10/7/23.
//
//  This sets up the data structure used by SolarEventManager.
//  A SolarDay receives solar event information from the sunrisesunset api.
//  The colorsAndTimes method processes this information into an array that
//  can easily be converted into color stops.

import CoreLocation
import Foundation
import SwiftUI

struct Results: Codable {
    let results: SolarDay
    let status: String
}

struct SolarDay: Codable {
    let date: String
    let sunrise: String
    let sunset: String
    let first_light: String
    let last_light: String
    let dawn: String
    let dusk: String
    let solar_noon: String
        
    static let calendar = Timeline.shared.calendar
    
    // Date formatter
    static var df: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "YYYY-MM-dd"
        return df
    }
    
    // Time formatter
    static var tf: DateFormatter {
        let tf = DateFormatter()
        tf.dateFormat = "h:mm:ss a YYYY-MM-dd"
        return tf
    }
    
    // Unwrapped date
    var dateDate: Date {
        SolarDay.df.date(from: date) ?? Date()
    }
        
    // Each of the following returns a time value in seconds.
    var firstLightTime: Double {
        SolarDay.tf.date(from: first_light + " " + date)!.timeIntervalSince1970
    }
    
    var dawnTime: Double {
        SolarDay.tf.date(from: dawn + " " + date)!.timeIntervalSince1970
    }
    
    var sunriseTime: Double {
        SolarDay.tf.date(from: sunrise + " " + date)!.timeIntervalSince1970
    }
    
    var solarNoonTime: Double {
        SolarDay.tf.date(from: solar_noon + " " + date)!.timeIntervalSince1970
    }
    
    var sunsetTime: Double {
        SolarDay.tf.date(from: sunset + " " + date)!.timeIntervalSince1970
    }
    
    var duskTime: Double {
        SolarDay.tf.date(from: dusk + " " + date)!.timeIntervalSince1970
    }
    
    var lastLightTime: Double {
        SolarDay.tf.date(from: last_light + " " + date)!.timeIntervalSince1970
    }
    
    var colorsAndTimes: [(Color, Double)] {
        
        // Creates a color and absolute time coordinate for each color stop within the day.
        return [
            (color: .midnight, time: firstLightTime),
            (color: .morning, time: dawnTime),
            (color: .sunrise, time: sunriseTime),
            // Noon color spreads over 80% of the gap between sunrise and sunset;
            // To adjust, change 0.80 to a different percentage.
            (color: .noon, time: solarNoonTime - 0.80 * (solarNoonTime - sunriseTime)),
            (color: .noon, time: solarNoonTime + 0.80 * (sunsetTime - solarNoonTime)),
            (color: .sunset, time: sunsetTime),
            (color: .evening, time: duskTime),
            (color: .midnight, time: lastLightTime)
        ]
    }
    
    var numberOfEvents: Int {
        colorsAndTimes.count
    }
}

extension SolarDay {
    
    init(day: StoredSolarDay) {
        sunrise = day.sunrise!
        sunset = day.sunset!
        first_light = day.first_light!
        last_light = day.last_light!
        dawn = day.dawn!
        dusk = day.dusk!
        solar_noon = day.solar_noon!
        date = day.date!
    }
}

extension StoredSolarDay {
    
    convenience init(day: SolarDay) {
        self.init()
        sunrise = day.sunrise
        sunset = day.sunset
        first_light = day.first_light
        last_light = day.last_light
        dawn = day.dawn
        dusk = day.dusk
        solar_noon = day.solar_noon
        date = day.date
    }
}
