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
    // dateString needs to be a var so it can be assigned as needed by fetchBackup in the solar days manager.
    var dateString: String
    
    
    static let calendar = Timeline.calendar
    
    // Convert this solar day's date to date and time for start of day
    // Serves as id for this solar day; do not remove.
    var date: Date {
        let df = DateFormatter()
        df.dateFormat = "YYYY-MM-dd"
        return SolarDay.calendar.startOfDay(for: df.date(from: dateString)!)
    }
    
    // Date formatter for time with dateString
    static var tf: DateFormatter {
        let tf = DateFormatter()
        tf.dateFormat = "h:mm:ss a YYYY-MM-dd"
        return tf
    }
        
    // Each of the following returns a time value in seconds.
    var firstLightTime: Double {
        SolarDay.tf.date(from: first_light + " " + dateString)!.timeIntervalSince1970
    }
    
    var dawnTime: Double {
        SolarDay.tf.date(from: dawn + " " + dateString)!.timeIntervalSince1970
    }
    
    var sunriseTime: Double {
        SolarDay.tf.date(from: sunrise + " " + dateString)!.timeIntervalSince1970
    }
    
    var solarNoonTime: Double {
        SolarDay.tf.date(from: solar_noon + " " + dateString)!.timeIntervalSince1970
    }
    
    var sunsetTime: Double {
        SolarDay.tf.date(from: sunset + " " + dateString)!.timeIntervalSince1970
    }
    
    var duskTime: Double {
        SolarDay.tf.date(from: dusk + " " + dateString)!.timeIntervalSince1970
    }
    
    var lastLightTime: Double {
        SolarDay.tf.date(from: last_light + " " + dateString)!.timeIntervalSince1970
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
        golden_hour = day.golden_hour!
        day_length = day.day_length!
        timezone = day.timezone!
        utc_offset = Int(exactly: day.utc_offset)!
        dateString = day.dateString!
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
        golden_hour = day.golden_hour
        day_length = day.day_length
        timezone = day.timezone
        utc_offset = Int16(exactly: day.utc_offset) ?? 0
        dateString = day.dateString
    }
}
