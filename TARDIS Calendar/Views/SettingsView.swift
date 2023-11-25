//
//  SettingsView.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 11/19/23.
//
//  This view allows the user to set up their calendars.
//  Other options and settings may be added soon.
//

import Foundation
import SwiftUI
import EventKit

struct SettingsView: View {
    
    // The controls here actually change values in the calendarSet model.
    @Binding var calendarSet: CalendarSet
    @Environment(\.dismiss) var dismiss
    
    // Shows an alert when there are no calendars selected.
    @State var selectACalendarAlert = false
    
    var body: some View {
        
        VStack {
            Text("Settings")
                .font(.largeTitle)
            
            NavigationView {
                
                // Lists all calendars present in the user's Apple Calendar App.
                List($calendarSet.appleCalendars) {$calendar in
                    HStack {
                        // Use toggles to mark which calendars this app will display events from.
                        Toggle("Use this calendar", isOn: $calendar.isSelected)
                            .labelsHidden()
                            .padding()
                            .background(.white)
                        Text("    \"\(calendar.title)\" - Display as:")
                        // Attatches a calendar type to each calendar
                        // TODO: - figure out how to only show the picker if the calendar is selected?
                        Picker("Select a type:", selection: $calendar.type) {
                            ForEach(CalendarType.allCases) {type in
                                Text(type.rawValue)
                            }
                        }
                        .labelsHidden() // Needed to do this to control the spacing between label and options; otherwise there's a huge gap!
                        Spacer()
                    }
                    .background(calendar.color)
                    
                } // End of calendars list
                .navigationTitle("Choose Calendars to Display")
                
                
            } // End of NavigationView
            
        }
        .alert("Please select at least one calendar to show.", isPresented: $selectACalendarAlert) {
            Button("Okay", role: .cancel, action: {})
        }
        
        Button("Done") {
            
            let count = calendarSet.appleCalendars.filter({$0.isSelected}).count
            if count > 0 {
                // Saves these settings to UserDefaults
                calendarSet.saveUserCalendars()
                dismiss()
            } else {
                selectACalendarAlert = true
            }
        }
        .buttonStyle(.borderedProminent)
    }
}




