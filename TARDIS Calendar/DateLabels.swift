//
//  DateLabels.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 7/23/23.
//

import Foundation
import SwiftUI

struct DateLabelView: View {
    
    var labelText: String
    var xLocation: Double
    
    var body: some View {
        VStack {
            Text(labelText).padding([.top,.leading,.trailing], 5).background(.white).foregroundColor(.blue)
            Text("▼").foregroundColor(.white).offset(y:-5)
        }
    }
}


func dateLabelArray(span: TimeInterval, now: Date) -> [DateLabelView] {
    
    // Set up initial values
    let time = Time(span: span)
    let calendar = Time.calendar
    let leadingDate = time.leadingDate
    let trailingDate = time.trailingDate
    let trailingTime = time.trailingTime
    
    // Calculate the number of hours represented on screen.
    let onScreenHours = calendar.dateComponents([.hour], from: leadingDate, to: trailingDate).hour!
    
    // Initialize an array of labels to return
    var dateLabelArray: [DateLabelView] = []
    
    // Show hours or days with the labels, depending on the number of hours on screen.
    switch onScreenHours {
        
    case 0...Int(20/(1.0 - Settings.nowLocation)):
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
            let labelView = DateLabelView(labelText: label, xLocation: x)
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
            let labelView = DateLabelView(labelText: label, xLocation: x)
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
        return ((1.0 - Settings.nowLocation) * x + Settings.nowLocation * trailingTime - currentTime) / (trailingTime - currentTime)
    }
}
