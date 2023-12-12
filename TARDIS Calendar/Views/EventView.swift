//
//  Events.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 8/2/23.
//
//  Displays each event as a circle with an icon, which can be expanded to show more information.
//

import Foundation
import SwiftUI
import EventKit


struct EventView: View {
    
    let event: Event
    
    // TODO: - Figure out how to animate transitions from regular to expanded format and back.
    @Binding var isExpanded: Bool
    
    let shrinkFactor: Double
    let screenWidth: Double
    @EnvironmentObject var timeline:Timeline
    
    // Adjust to change the size of an event icon (unexpanded view)
    // All other dimensions are derived from this number.
    // TODO: - Derive this number from the size of the screen. (screenWidth above)
    let size: Double = 60.0
    
    // Adjust to change the size of an expanded view.
    let sizeMultiplyer = 3.5
    
    // Each veiw has an arrow on the timeline; this places it correctly. Do not adjust.
    let arrowOffset: Double = -7.75
    
    // Date() stores the current time when this view is created. This keeps all calculations consistant.
    // Event views are destroyed and re-created once per second.
    let now = Date()
    
    var timeRemaining: String {
        var dayString = ""
        var hourString = ""
        var minuteString = ""
        let parts = Timeline.calendar.dateComponents([.day, .hour, .minute], from: now, to: event.startDate)
        if let day = parts.day {
            dayString = day == 0 ? "" : ("\(day) day" + (day == 1 ? ", " : "s, "))
        }
        if let hour = parts.hour {
            hourString = hour == 0 ? "" : ("\(hour) hour" + (hour == 1 ? ", " : "s, "))
        }
        if let minute = parts.minute {
            minuteString = minute == 0 ? "less than one minute" : ("\(minute) minute" + (minute == 1 ? "." : "s."))
        }
        return(dayString + hourString + minuteString)
    }
    
    // Expands the event View when true and keeps it in place while the event is happening, starting 15 minutes beforehand.
    var eventIsNow: Bool {
        ((event.startDate - 60 * 15)...event.endDate).contains(now)
    }
    
    // This offset value keeps the event view centered over Now while the event is happening.
    var offsetAmount: Double {
        if eventIsNow {
            return screenWidth * (Timeline.nowLocation - timeline.unitX(fromTime: event.startDate.timeIntervalSince1970))
        } else {
            return 0.0
        }
    }
    
    // Seems I may have re-invented the wheel here.
    // TODO: - look into swift's built-in time descriptions.
    var descriptionOfTimeRemaining: String {
        guard event.startDate > now else {
            return ""
        }
        let components = Timeline.calendar.dateComponents([.day, .hour, .minute], from: now, to: event.startDate)
        let days = components.day ?? 0
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        var description = "Coming up in "
        
        if days >= 1 {
            let plural = (days == 1) ? "." : "s."
            switch hours {
            case 0..<3:
                description += "about \(days.lowerName()) day" + plural
            case 3..<9:
                description += "more than \(days.lowerName()) day" + plural
            case 9..<15:
                description += "about \(days.lowerName()) and a half days."
            case 15..<21:
                description += "less than \((days + 1).lowerName()) days."
            case 21..<24:
                description += "about \((days + 1).lowerName()) days."
            default:
                description += "\(days.lowerName()) day" + plural
            }
        } else if hours >= 1 {
            let plural = (hours == 1) ? "." : "s."
            switch hours {
            case 0..<11:
                switch minutes {
                case 0..<5:
                    description += "about \(hours.lowerName()) hour" + plural
                case 5..<20:
                    description += "more than \(hours.lowerName()) hour" + plural
                case 20..<40:
                    description += "about \(hours.lowerName()) and a half hours."
                case 40..<55:
                    description += "less than \((hours + 1).lowerName()) hours."
                case 55..<60:
                    description += "about \((hours + 1).lowerName()) hours."
                default:
                    description += "\(hours.lowerName()) hour" + plural
                }
            case 11..<13:
                description += "about half a day."
            case 13..<22:
                description += "less than a day."
            case 22..<24:
                description += "about one day."
            default:
                description += "\(hours.lowerName()) hour" + plural
            }
        } else {
            let plural = (minutes == 0) ? "." : "s."
            switch minutes {
            case 0..<20:
                description += "less than \((minutes + 1).lowerName()) minute" + plural
            case 20..<40:
                description += "about half an hour."
            case 40..<55:
                description += "less than an hour."
            case 55..<60:
                description += "about an hour."
            default:
                description += "less than \((minutes + 1).lowerName()) minute" + plural
            }
        }
        return description
    }
    
    // Makes dictionary of user calendars available; used to determine the calendar type for this event.
    var calendars: [String: String] =
    UserDefaults.standard.dictionary(forKey: "calendars") as? [String: String] ?? ["":""]
    
    
    // Each calendar type has an associated icon in the CalendarType enum.
    // Use the "daily" icon as a default in case something goes wrong.
    var icon: Image {
        if let icon = CalendarType(rawValue: calendars[event.calendarTitle] ?? CalendarType.daily.rawValue)?.icon() {
            return icon
        } else {
            return CalendarType.daily.icon()
        }
    }
    
    var color: Color {
        event.calendarColor
    }
    
    // shrinkFactor is passed in, but only use it to shrink low-priority event icons.
    var shrink: Double {
       return event.priority <= 2 ? shrinkFactor : 1.0
    }
    
    // Here is the "normal" icon-based event view, when it isn't expanded.
    var iconView: some View {
        
        ZStack {
            Circle()
                .foregroundColor(.yellow)
                .frame(width: size * shrink, height: size * shrink)
            icon
                .resizable()
                .foregroundColor(color)
                .frame(width: size * 0.95 * shrink, height: size * 0.95 * shrink, alignment: .center)
        } // End of ZStack
        .opacity(eventIsNow ? 0.0 : 1.0)
        .onTapGesture {
            isExpanded = true
        }
    } // End of iconView
    
    
    // Here is the actual EventView, composed of ArrowView (separate file), IconView, and an expanded view.
    var body: some View {
        
        if event.endDate > now {
            
            Group {
                ArrowView (size: size * shrink)
                    .zIndex(-6)
                iconView
                    .zIndex((event.endDate > now) ? Double(event.priority) : Double(event.priority) - 5)
                
                
                // Shows expanded view if either the user taps or the event is currently happening.
                if isExpanded || eventIsNow {
                    
                    ZStack {
                        
                        Circle()
                            .foregroundColor(.yellow)
                            .opacity(0.85)
                            .frame(width: size * sizeMultiplyer, height: size * sizeMultiplyer)
                        
                        VStack {
                            Text(event.title)
                                .font(.headline)
                            if let notes = event.event.notes {
                                Text(notes)
                                    .font(.caption)
                            }
                            Text("at " + event.startDate.formatted(date: .omitted, time:.shortened))
                            Spacer()
                            
                            if now < event.startDate {
                                Text("Coming up in \(timeRemaining)")
                            } else if now < event.endDate {
                                Text("HAPPENING NOW\n")
                            } else {
                                Text("Done!\n")
                            }
                        }
                        .frame(width: size * sizeMultiplyer * 0.8, height: size * sizeMultiplyer * 0.85)
                        .multilineTextAlignment(.center) // Necessary??
                        
                        
                    } // End of expanded view ZStack
                    .zIndex(Double(event.priority + 10))
                    .onTapGesture {
                        isExpanded = false
                    }
                } // End of expanded View
            } // End of main Group
            .offset(x:offsetAmount, y:0.0)
            
        } else {
            // if event has passed, return an empty view
        }
        
    } // End of view
        
} // End of struct

