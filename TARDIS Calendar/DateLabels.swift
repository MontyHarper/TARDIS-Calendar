//
//  DateLabels.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 7/23/23.
//

import Foundation
import SwiftUI

struct DateLabelView: View {
    
    @State var labelText: String
    var xLocation: Double
    
    var body: some View {
        Text(labelText).padding(5).background(.white).foregroundColor(.blue)
    }
}

func dateLabelArray(_ trailingTime: Double) -> [DateLabelView] {
    
    // Set up initial values
    let now = Date().timeIntervalSince1970
    let leadingTime = now - (trailingTime - now) / 4
    let calendar = Days.calendar
    let leadingDate = Date(timeIntervalSince1970: leadingTime)
    let trailingDate = Date(timeIntervalSince1970: trailingTime)
    
    // Calculate the number of hours represented on screen.
    let onScreenHours = calendar.dateComponents([.hour], from: leadingDate, to: trailingDate).hour!
    
    // Initialize an array of labels to return
    var dateLabelArray: [DateLabelView] = []
    
    // Show hours or days with the labels, depending on the number of hours on screen.
    switch onScreenHours {
        
    case 0...8:
        // labels will show hours of the day
        
        // Begin at the start of the first hour in the leading date
        let dayHour = calendar.dateComponents([.year, .month, .day, .hour], from: leadingDate)
        var hour = calendar.date(from: dayHour)!

        
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
            hour = calendar.date(byAdding: .hour, value: 1, to: hour)!
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
        return (0.8 * x + 0.2 * trailingTime - now) / (trailingTime - now)
    }
}
