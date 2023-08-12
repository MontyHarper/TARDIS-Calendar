//
//  Reference.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 7/27/23.
//
//  This file contains important numbers and information referenced by the rest of the app.
//

import Foundation
import SwiftUI


 /*
  User-settable parameters for the app.
  For now these values are set here, but they should become accessible to users at some point.
  In the meantime it's convenient for me to play with changes from here.
  */

struct Settings {
    static let maxFutureDays: Int = 14 // Number of days into the future the calendar can display.
    static let hoursOnScreen: Double = 12 // Number of hours to show on screen when calendar reverts to default mode.
    static let nowLocation: Double = 0.2 // Percentage of the screen to the left of now.
    static let calendar = Calendar.autoupdatingCurrent // Sets the app's calendar to the user's chosen calendar for the device.
    static let userImage = Image("Mom")
}



// Instances of Time are used to calculate calendar view elements.
// Note that much of the calculations are due to the fact that my fixed point on the screen (now) occurs partway across the screen.

struct Time {
    
    static var calendar = Settings.calendar
    static var minSpan: TimeInterval = 3600 // minimum time shown on screen is one hour, in seconds
    static var maxSpan: TimeInterval {
        // Calculating maximum time span using the calendar.
        let now = Date().timeIntervalSince1970
        let maxDay2 = Time.calendar.date(byAdding: .day, value: Settings.maxFutureDays, to: Date())!.timeIntervalSince1970
        let maxDay1 = now - Settings.nowLocation * (maxDay2 - now)/(1.0 - Settings.nowLocation)
        return maxDay2 - maxDay1
    }
    static var defaultSpan: TimeInterval = Settings.hoursOnScreen * 3600
    

    
    var now = Date().timeIntervalSince1970 // current time in seconds
    var span: TimeInterval // amount of time shown on screen in seconds; adjustable by user in real time.
    var leadingDate: Date // Date and time represented by the left edge of the screen.
    var trailingDate: Date // Date and time represented by the right edge of the screen.
    var leadingTime: Double // time at the left edge of the screen in seconds.
    var trailingTime: Double // time at the right edge of the screen in seconds.

    
    init(span: TimeInterval) {
        self.span = span
        leadingDate = Date(timeIntervalSince1970: now - Settings.nowLocation * span)
        trailingDate = Date(timeIntervalSince1970: now + (1.0 - Settings.nowLocation) * span)
        leadingTime = leadingDate.timeIntervalSince1970
        trailingTime = trailingDate.timeIntervalSince1970
    }
    
    func dateToDouble(_ x:Double) -> Double {
        
        // linear transformation changing a given date x into a percent length of the screen.
        
        return ((1.0 - Settings.nowLocation) * x + Settings.nowLocation * trailingTime - now) / (trailingTime - now)
    }
    
}


// These are the colors to use to represent different times of the day.
extension Color {
    static var midnight = Color(hue: 0.668944, saturation: 1.0, brightness: 0.267304)
    static var sunrise = Color(hue: 0.105191, saturation: 0.763661, brightness: 1.0)
    static var morning = Color(hue: 0.544171, saturation: 0.579690, brightness: 1.0)
    static var noon = Color(hue: 0.544171, saturation: 0.223588, brightness: 1.0)
    static var evening = Color(hue: 0.610656, saturation: 0.546903, brightness: 0.819217)
    static var sunset = Color(hue: 0.824681, saturation: 0.420310, brightness: 0.964025)
}


// This function is used to interpolate colors at the edges of the screen.
extension Color {
    func parts () -> (hue: Double, saturation: Double, brightness: Double) {
        let cgColor = self.cgColor
        let uiColor = UIColor(cgColor: cgColor!)
        var (h,s,b,a) = (CGFloat.zero,CGFloat.zero,CGFloat.zero,CGFloat.zero)
        let _ = uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (hue: Double(h), saturation: Double(s), brightness: Double(b))
    }
}



// These are the types of color stop.
// Will add a function to return the time for each stop as a percentage of the day.

enum ColorStop {
    case dawn
    case sunrise
    case morning
    case noon
    case evening
    case sunset
    case dusk
    case midnight
}


extension Int {
    
    func name() -> String {
        
        switch self {
        case 1: return "One"
        case 2: return "Two"
        case 3: return "Three"
        case 4: return "Four"
        case 5: return "Five"
        case 6: return "Six"
        case 7: return "Seven"
        case 8: return "Eight"
        case 9: return "Nine"
        case 10: return "Ten"
        case 11: return "Eleven"
        case 12: return "Twelve"
        case 13: return "Thirteen"
        case 14: return "Fourteen"
        case 15: return "Fifteen"
        case 16: return "Sixteen"
        case 17: return "Seventeen"
        case 18: return "Eighteen"
        case 19: return "Nineteen"
        case 20: return "Twenty"
        case 21: return "Twenty One"
        case 22: return "Twenty Two"
        case 23: return "Twenty Three"
        case 24: return "Twenty Four"
        default: return "Many"
        }
    }
}




