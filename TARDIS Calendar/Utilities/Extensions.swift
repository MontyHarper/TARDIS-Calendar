//
//  Reference.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 7/27/23.
//
//  Extensions to make life easier.
//

import Foundation
import SwiftUI


// These are the colors to use to represent different times of the day.
extension Color {
    static var midnight = Color(hue: 0.668944, saturation: 1.0, brightness: 0.267304)
    static var sunrise = Color(hue: 0.158652, saturation: 0.329797, brightness: 1.0)
    static var morning = Color(hue: 0.544171, saturation: 0.579690, brightness: 1.0)
    static var noon = Color(hue: 0.583333, saturation: 0.647086, brightness: 1.0)
    static var evening = Color(hue: 0.610656, saturation: 0.546903, brightness: 0.819217)
    static var sunset = Color(hue: 0.824681, saturation: 0.420310, brightness: 0.964025)
}


// This function returns the parts of a color and is used in interpolating values between two colors.
extension Color {
    func parts () -> (hue: Double, saturation: Double, brightness: Double) {
        let cgColor = self.cgColor
        let uiColor = UIColor(cgColor: cgColor!)
        var (h,s,b,a) = (CGFloat.zero,CGFloat.zero,CGFloat.zero,CGFloat.zero)
        let _ = uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (hue: Double(h), saturation: Double(s), brightness: Double(b))
    }
}

 // This function returns a string naming an integer. I may be reinventing the wheel with this one!
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
    
    // This variation returns a lowercased string for the name of an integer.
    func lowerName() -> String {
        self.name().lowercased()
    }
}


extension Date {
    
    var relativeTimeDescription: String {
        
        let nowRange = Date().addingTimeInterval(-10)...Date().addingTimeInterval(10)
        
        if nowRange.contains(self) {
            return "Now"
        } else {
            
            let components = Timeline.calendar.dateComponents([.day, .hour, .minute], from: Date(), to: self)
            
            let days = abs(components.day ?? 0)
            let hours = abs(components.hour ?? 0)
            let minutes = abs(components.minute ?? 0)
            var description = ""
            
            if days >= 1 {
                let plural = (days == 1) ? "" : "s"
                switch hours {
                case 0..<3:
                    description += "about \(days.lowerName()) day" + plural
                case 3..<9:
                    description += "more than \(days.lowerName()) day" + plural
                case 9..<15:
                    description += "about \(days.lowerName()) and a half days"
                case 15..<21:
                    description += "less than \((days + 1).lowerName()) days"
                case 21..<24:
                    description += "about \((days + 1).lowerName()) days"
                default:
                    description += "\(days.lowerName()) day" + plural
                }
            } else if hours >= 1 {
                let plural = (hours == 1) ? "" : "s"
                switch hours {
                case 0..<11:
                    switch minutes {
                    case 0..<5:
                        description += "about \(hours.lowerName()) hour" + plural
                    case 5..<20:
                        description += "more than \(hours.lowerName()) hour" + plural
                    case 20..<40:
                        description += "about \(hours.lowerName()) and a half hours"
                    case 40..<55:
                        description += "less than \((hours + 1).lowerName()) hours"
                    case 55..<60:
                        description += "about \((hours + 1).lowerName()) hours"
                    default:
                        description += "\(hours.lowerName()) hour" + plural
                    }
                case 11..<13:
                    description += "about half a day"
                case 13..<22:
                    description += "less than a day"
                case 22..<24:
                    description += "about one day"
                default:
                    description += "\(hours.lowerName()) hour" + plural
                }
            } else {
                let plural = (minutes == 0) ? "" : "s"
                switch minutes {
                case 0..<20:
                    description += "less than \((minutes + 1).lowerName()) minute" + plural
                case 20..<40:
                    description += "about half an hour"
                case 40..<55:
                    description += "less than an hour"
                case 55..<60:
                    description += "about an hour"
                default:
                    description += "less than \((minutes + 1).lowerName()) minute" + plural
                }
            }
            return description + (self > Date() ? " from now" : " ago")
        }
    }
}
