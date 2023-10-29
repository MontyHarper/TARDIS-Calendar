//
//  SolarDay.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 10/7/23.
//

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
    let dateString: String
    
    
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
            // Noon color spreads over 75% of the gap between sunrise and sunset;
            // To adjust, change 0.75 to a different percentage.
            (color: .noon, time: solarNoonTime - 0.75 * (solarNoonTime - sunriseTime)),
            (color: .noon, time: solarNoonTime + 0.75 * (sunsetTime - solarNoonTime)),
            (color: .sunset, time: sunsetTime),
            (color: .evening, time: duskTime),
            (color: .midnight, time: lastLightTime)
        ]
    }
    
}


