//
//  Events.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 8/2/23.
//

import Foundation
import SwiftUI
import EventKit



struct EventView: View {
    
    let event: Event
    @Binding var isExpanded: Bool
    let shrinkFactor: Double
    
    // Adjust to change the size of an event icon (unexpanded view)
    let size: Double = 60.0
    
    // Adjust to change the size of an expanded view; used to animate, in theory
    @State var sizeMultiplyer = 4.0
    
    // Each veiw has an arrow on the timeline; this places it correctly. Do not adjust.
    let arrowOffset: Double = -7.75
    
    // A set now value won't change values while the view renders, risking problems with the logic.
    let now = Date()
    
    var timeToEvent: TimeInterval {
        event.startDate.timeIntervalSince1970 - Date().timeIntervalSince1970
    }
    
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
    // Each calendar has a type that is user-defined, not inherent to the event's calendar in EKEvents.
    var calendars: [String: String] {
        UserDefaults.standard.dictionary(forKey: "calendars") as! [String: String]
    }
    
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
    
    // Only shrink low-priority event icons.
    var shrink: Double {
        print("shrink factor \(shrinkFactor)")
       return event.priority <= 2 ? shrinkFactor : 1.0
    }
    
    var iconView: some View {
        
        ZStack {
            
            Circle()
                .foregroundColor(.yellow)
                .frame(width: size * shrink, height: size * shrink)
            icon
                .resizable()
                .foregroundColor(color)
                .frame(width: size * 0.95 * shrink, height: size * 0.95 * shrink, alignment: .center)
        }
        .onTapGesture {
            withAnimation {
                sizeMultiplyer = 4.0
                isExpanded = true
            }
        }
    }
    
    var arrowView: some View {
        
        Circle()
            .foregroundColor(.clear)
            .frame(width: size * shrink, height: size * shrink)
            .overlay(
                Image(systemName: "arrow.right")
                    .offset(x: -size * 0.5 * shrink + arrowOffset)
                    .foregroundColor(.black)
                    .shadow(color: .white, radius: 3),
                alignment: .init(horizontal: .center, vertical: .center))
    }
    
    
    var body: some View {
        
        arrowView
            .zIndex(0.0)
        iconView
            .zIndex((event.endDate > now) ? Double(event.priority) : 0)
        
        
        if isExpanded {
                        
            ZStack {
                
                Circle()
                    .foregroundColor(.yellow)
                    .opacity(0.75)
                    .frame(width: size * sizeMultiplyer, height: size * sizeMultiplyer)
                
                VStack {
                    Text(event.title)
                        .font(.headline)
                    Text(event.event.notes ?? "")
                        .font(.caption)
                    Spacer()
                    
                    if now < event.startDate {
                        Text(descriptionOfTimeRemaining)
                            .font(.caption)
                        Text(timerInterval: now...event.startDate)
                    } else if now < event.endDate {
                        Text("HAPPENING NOW!\n")
                    } else {
                        Text("Done!\n")
                    }
                }
                .frame(width: size * sizeMultiplyer * 0.75, height: size * sizeMultiplyer * 0.8)
                .multilineTextAlignment(.center)
                
            }
            .zIndex(Double(event.priority + 10))
            .onTapGesture {
                isExpanded = false
                withAnimation {
                    sizeMultiplyer = 1.0
                }
            }
        }
    } // End of body
        
}

