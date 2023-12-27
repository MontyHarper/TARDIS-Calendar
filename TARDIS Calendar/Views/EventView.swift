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
    @EnvironmentObject var size: Dimensions
    @EnvironmentObject var eventManager: EventManager
    
    // TODO: - Figure out how to animate transitions from regular to expanded format and back.
    @Binding var isExpanded: Bool
    
    let shrinkFactor: Double
    let screenWidth: Double
    @EnvironmentObject var timeline:Timeline
        
    // Each veiw has an arrow on the timeline; this places it correctly. Do not adjust.
    let arrowOffset: Double = -7.75
    
    // Date() stores the current time when this view is created. This keeps all calculations consistant.
    // Event views are destroyed and re-created once per second.
    let now = Date()
    
    var atTime: String {
        let eventDay = Timeline.calendar.component(.day, from: event.startDate)
        let today = Timeline.calendar.component(.day, from: Date())
        let eventIsToday: Bool = (eventDay == today)
        let eventIsTomorrow: Bool = (eventDay == (today + 1))
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        let dayOfWeek = formatter.string(from: event.startDate)
        let dayText = eventIsToday ? " Today" : (eventIsTomorrow ? " Tomorrow" : " \(dayOfWeek)")
        return ("at " + event.startDate.formatted(date: .omitted, time: .shortened) + dayText)
    }
    
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
                .frame(width: size.smallEvent * shrink, height: size.smallEvent * shrink)
            icon
                .resizable()
                .foregroundColor(color)
                .frame(width: size.smallEvent * 0.95 * shrink, height: size.smallEvent * 0.95 * shrink)
        } // End of ZStack
        .onLongPressGesture(minimumDuration: 0.05, maximumDistance: 20.0) {
            eventManager.expandEvent(event: event)
        }
    } // End of iconView
    
    
    // Here is the actual EventView, composed of ArrowView (separate file), IconView, and an expanded view.
    var body: some View {
        
        if event.endDate > now {
            
            Group {
                ArrowView (size: (isExpanded || eventIsNow) ? size.largeEvent : size.smallEvent * shrink)
                    .zIndex(isExpanded ? 0 : -6)
                iconView
                    .zIndex(Double(event.priority))
                
                
                // Shows expanded view if either the user taps or the event is currently happening.
                if isExpanded || eventIsNow {
                    
                    ZStack {
                        
                        Circle()
                            .foregroundColor(eventIsNow ? .cyan : .yellow)
                            .opacity(eventIsNow ? 1.0 : 1.0)
                            .frame(width: size.largeEvent, height: size.largeEvent)
                        
                        VStack {
                            
                            Text(event.title)
                                .font(.system(size: size.fontSizeLarge, weight: .bold))
                                .multilineTextAlignment(.center)
                            if let notes = event.event.notes {
                                if !eventIsNow {
                                    Text(notes)
                                        .multilineTextAlignment(.center)
                                        .font(.system(size: size.fontSizeSmall))
                                }
                            }
                            
                            if now > event.startDate {
                                Text("HAPPENING NOW")
                                    .font(.system(size: size.fontSizeSmall, weight: .bold))
                            } else if eventIsNow {
                                Text("Coming up in \(timeRemaining)")
                                    .font(.system(size: size.fontSizeMedium))
                                    .multilineTextAlignment(.center)
                            } else {
                                Text(atTime)
                                    .font(.system(size: size.fontSizeMedium))
                            }
                            
                            
                                ZStack {
                                    Circle()
                                        .foregroundColor(.yellow)
                                        .frame(width: size.tinyEvent, height: size.tinyEvent)
                                    icon
                                        .resizable()
                                        .foregroundColor(color)
                                        .frame(width: size.tinyEvent * 0.95, height: size.tinyEvent * 0.95)
                                }

                            
                            if now < event.startDate && !eventIsNow {
                                Text("Coming up in \(timeRemaining)")
                                    .font(.system(size: size.fontSizeMedium))
                                    .multilineTextAlignment(.center)
                            }
                            
                                
                            if eventIsNow {
                                Text("The time is:")
                                    .font(.system(size: size.fontSizeSmall))
                                Text(Date().formatted(date: .omitted, time: .shortened))
                                    .font(.system(size: size.fontSizeLarge, weight: .black))
                            }
                            
                        }
                        .frame(width: size.largeEvent * 0.7, height: size.largeEvent * 0.8)

                        
                          
                        
                    } // End of expanded view ZStack
                    .zIndex(Double(event.priority + 10))
                    .onLongPressGesture(minimumDuration: 0.2, maximumDistance: 20.0) {
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

