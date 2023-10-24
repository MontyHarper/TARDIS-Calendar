//
//  DateLabels.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 7/23/23.
//

import Foundation
import SwiftUI



// This is the third approach. New 0ct 15 2023.
// I want to try relative labels; now, one hour, two hours, etc.

func dateLabelArray(timeline: Timeline) -> [TimeTickView] {
    
    // Set up initial values
    let calendar = Timeline.calendar
    let leadingDate = timeline.leadingDate
    let trailingDate = timeline.trailingDate
    let trailingTime = timeline.trailingTime
    
    // Calculate the number of hours represented on screen.
    let onScreenHours = calendar.dateComponents([.hour], from: leadingDate, to: trailingDate).hour!
    
    // Initialize an array of labels to return
    var dateLabelArray: [TimeTickView] = []
    
    // Show hours or days with the labels, depending on the number of hours on screen.
    switch onScreenHours {
        
    case 0...Int(24/(1.0 - Settings.shared.nowLocation)):
        // labels will show hours
        
        // Begin at the current time
        let reference = Date()
        var hour = Date()
        var skip: Int = 60
        switch onScreenHours {
        case 0...4: skip = 60
        case 5...8: skip = 120
        case 9...12: skip = 180
        default: skip = 180
        }
        
        // Iterate until the last hour
        while hour <= trailingDate {

            // Calculate location of label
            let x = dateToStop(hour.timeIntervalSince1970)
            
            // Calculate content of label
            let hours = calendar.dateComponents([.hour], from: reference, to: hour).hour!
            
            var label = ""
            switch hours {
            case 0: label = "Now"
            case 1: label = "One Hour"
            case 2: label = "Two Hours"
            case 3: label = "Three Hours"
            case 4: label = "Four Hours"
            case 5: label = "Five Hours"
            case 6: label = "Six Hours"
            case 7: label = "Seven Hours"
            case 8: label = "Eight Hours"
            case 9: label = "Nine Hours"
            case 10: label = "Ten Hours"
            case 11: label = "Eleven Hours"
            case 12: label = "Twelve Hours"
            default: label = "\(hours) Hours"
            }
        
            // Create the view for the label
            let labelView = TimeTickView(labelText: label, xLocation: x)
            
            
            // Add this view to the array
            dateLabelArray.append(labelView)
            
            // Advance the hour
            hour = calendar.date(byAdding: .minute, value: skip, to: hour)!
        }
        
        default:
        // labels will show days
        
        // Begin with the first day
        var day: Date = calendar.startOfDay(for: leadingDate)
        
        // Iterate until the last day
        while day <= calendar.startOfDay(for: trailingDate) {
            
            // Calculate location of label
            let noon = calendar.date(byAdding: .hour, value: 12, to: day)!.timeIntervalSince1970
            let x = dateToStop(noon)
            
            // Calculate content of label
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, MMM dd"
            let label = formatter.string(from: day)
        
            // Create the view for the label
            let labelView = TimeTickView(labelText: label, xLocation: x)
            
            // Erase previous view's text
            // (Only the rightmost view will get a text label)
            if dateLabelArray.count > 1 {
                dateLabelArray[dateLabelArray.count - 1].labelText = "◉"
            }
            
            // Add this view to the array
            dateLabelArray.append(labelView)
            
            // Advance the day
            day = calendar.date(byAdding: .day, value: 1, to: day)!
        }
        
    }
    
    return dateLabelArray
    
    // This function converts an actual date in seconds into a location on the screen.
    func dateToStop(_ x:Double) -> Double {
        
        // linear transformation changing a given date x into a percent length of the screen.
        let currentTime = timeline.now
        return ((1.0 - Timeline.nowLocation) * x + Timeline.nowLocation * trailingTime - currentTime) / (trailingTime - currentTime)
    }
}

func dateLabelArrayOriginal2(span: TimeInterval, now: Date) -> [TimeTickView] {
    
    // Set up initial values
    let time = Time(span: span)
    let calendar = Time.calendar
    let leadingDate = time.leadingDate
    let trailingDate = time.trailingDate
    let trailingTime = time.trailingTime
    
    // Calculate the number of hours represented on screen.
    let onScreenHours = calendar.dateComponents([.hour], from: leadingDate, to: trailingDate).hour!
    
    // Initialize an array of labels to return
    var dateLabelArray: [TimeTickView] = []
    
    // Show hours or days with the labels, depending on the number of hours on screen.
    switch onScreenHours {
        
    case 0...Int(24/(1.0 - Settings.shared.nowLocation)):
        // labels will show hours of the day
        
        // Begin at the start of the first hour beyond the leading date
        let dayHour = calendar.dateComponents([.year, .month, .day, .hour], from: leadingDate)
        var hour = calendar.date(from: dayHour)!
        let skip: Int = 60
        
        // Iterate until the last hour
        while hour <= trailingDate {

            // Calculate location of label
            let x = dateToStop(hour.timeIntervalSince1970)
            
            // Calculate content of label
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            let label = formatter.string(from: hour)
        
            // Create the view for the label
            let labelView = TimeTickView(labelText: label, xLocation: x)
            
            // Erase previous view's text
            // (Only the rightmost view will get a text label)
            if dateLabelArray.count > 1 {
                dateLabelArray[dateLabelArray.count - 1].labelText = "◉"
            }
            
            // Add this view to the array
            dateLabelArray.append(labelView)
            
            // Advance the hour
            hour = calendar.date(byAdding: .minute, value: skip, to: hour)!
        }
        
        default:
        // labels will show days
        
        // Begin with the first day
        var day: Date = calendar.startOfDay(for: leadingDate)
        
        // Iterate until the last day
        while day <= calendar.startOfDay(for: trailingDate) {
            
            // Calculate location of label
            let noon = calendar.date(byAdding: .hour, value: 12, to: day)!.timeIntervalSince1970
            let x = dateToStop(noon)
            
            // Calculate content of label
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, MMM dd"
            let label = formatter.string(from: day)
        
            // Create the view for the label
            let labelView = TimeTickView(labelText: label, xLocation: x)
            
            // Erase previous view's text
            // (Only the rightmost view will get a text label)
            if dateLabelArray.count > 1 {
                dateLabelArray[dateLabelArray.count - 1].labelText = "◉"
            }
            
            // Add this view to the array
            dateLabelArray.append(labelView)
            
            // Advance the day
            day = calendar.date(byAdding: .day, value: 1, to: day)!
        }
        
    }
    
    return dateLabelArray
    
    // This function converts an actual date in seconds into a location on the screen.
    func dateToStop(_ x:Double) -> Double {
        
        // linear transformation changing a given date x into a percent length of the screen.
        let currentTime = now.timeIntervalSince1970
        return ((1.0 - Settings.shared.nowLocation) * x + Settings.shared.nowLocation * trailingTime - currentTime) / (trailingTime - currentTime)
    }
}



// Going with a different approach.
// I'm leaving this function here for reference and in case I want to come back to it.
func dateLabelArrayOriginal(span: TimeInterval, now: Date) -> [TimeTickView] {
    
    // Set up initial values
    let time = Time(span: span)
    let calendar = Time.calendar
    let leadingDate = time.leadingDate
    let trailingDate = time.trailingDate
    let trailingTime = time.trailingTime
    
    // Calculate the number of hours represented on screen.
    let onScreenHours = calendar.dateComponents([.hour], from: leadingDate, to: trailingDate).hour!
    
    // Initialize an array of labels to return
    var dateLabelArray: [TimeTickView] = []
    
    // Show hours or days with the labels, depending on the number of hours on screen.
    switch onScreenHours {
        
    case 0...Int(20/(1.0 - Settings.shared.nowLocation)):
        // labels will show hours of the day
        
        // Begin at the start of the first hour beyond the leading date
        let dayHour = calendar.dateComponents([.year, .month, .day, .hour], from: leadingDate)
        var hour = calendar.date(from: dayHour)!
        var skip: Int {
            switch onScreenHours {
            case 0...3: return 30
            case 4...6: return 60
            case 7...9: return 90
            case 10...12: return 120
            case 13...15: return 180
            default: return 240
            }
        }
        
        // Iterate until the last hour
        while hour <= trailingDate {

            // Calculate location of label
            let x = dateToStop(hour.timeIntervalSince1970)
            
            // Calculate content of label
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            let label = formatter.string(from: hour)
        
            // Create the view for the label
            let labelView = TimeTickView(labelText: label, xLocation: x)
            dateLabelArray.append(labelView)
            
            // Advance the hour
            hour = calendar.date(byAdding: .minute, value: skip, to: hour)!
        }
        
        default:
        // labels will show days
        
        // Begin with the first day
        var day: Date = calendar.startOfDay(for: leadingDate)
        
        // Iterate until the last day
        while day <= calendar.startOfDay(for: trailingDate) {
            
            // Calculate location of label
            let noon = calendar.date(byAdding: .hour, value: 12, to: day)!.timeIntervalSince1970
            let x = dateToStop(noon)
            
            // Calculate content of label
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, MMMM dd"
            let label = formatter.string(from: day)
        
            // Create the view for the label
            let labelView = TimeTickView(labelText: label, xLocation: x)
            dateLabelArray.append(labelView)
            
            // Advance the day
            day = calendar.date(byAdding: .day, value: 1, to: day)!
        }
        
    }
    
    return dateLabelArray
    
    // This function converts an actual date in seconds into a location on the screen.
    func dateToStop(_ x:Double) -> Double {
        
        // linear transformation changing a given date x into a percent length of the screen.
        let currentTime = now.timeIntervalSince1970
        return ((1.0 - Settings.shared.nowLocation) * x + Settings.shared.nowLocation * trailingTime - currentTime) / (trailingTime - currentTime)
    }
}


// returns a label for current date
struct DateLabel: View {
    
    var timeline: Timeline
    
    var formatter:DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MMM d"
        return formatter
    }
    
    var body: some View {
        
        let now = Date(timeIntervalSince1970: timeline.now)
        VStack {
            Text(now, format: .dateTime.hour().minute())
            Text(formatter.string(from: now))
        }
        .padding(5)
        .background(.white)
        .opacity(0.75)
        .foregroundColor(.blue)
        .fontWeight(.black)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 5)))
    }
}
 

// returns a label for span of time
func timeSpanLabel(_ timespan:TimeInterval) -> String {
    
    var labelText = ""
    let futureSpan = timespan * 0.8
    let components:Set<Calendar.Component> = [.day, .hour, .minute]
    let result = Settings.shared.calendar.dateComponents(components, from: Date(), to: Date() + futureSpan)
    
    var days = result.day ?? 0
    var hours = result.hour ?? 0
    var minutes = result.minute ?? 0
    let totalHours = days * 24 + hours
    
    if totalHours > 12 {
        days += 1
        labelText = days == 1 ? "← One Day →" : "← \(days.name()) Days →"
    } else {
        if minutes > 30 {
            hours += 1
        }
        labelText = hours == 1 ? "← One Hour →" : "← \(hours.name()) Hours →"
    }
    
    return labelText
}


// returns a label for time or date at right edge of screen
