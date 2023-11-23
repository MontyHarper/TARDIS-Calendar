//
//  SettingsView.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 11/19/23.
//

import Foundation
import SwiftUI
import EventKit

struct SettingsView: View {
    
    @Binding var calendarSet: CalendarSet
    @Environment(\.dismiss) var dismiss
    
    @State var selectACalendarAlert = false
    
    var body: some View {
        
        VStack {
            Text("Settings")
                .font(.largeTitle)
            NavigationView {
                List($calendarSet.appleCalendars) {$calendar in
                    HStack {
                        Toggle("Use this calendar", isOn: $calendar.isSelected)
                            .labelsHidden()
                        Rectangle()
                            .foregroundColor(calendar.color)
                            .frame(width:25, height:25)
                        Text(calendar.title + ".")
                        Spacer()
                        Picker("Select a type:", selection: $calendar.type) {
                            ForEach(CalendarType.allCases) {type in
                                Text(type.rawValue)
                            }
                        }
                        .labelsHidden()
                    }
                }
                .navigationTitle("Choose Calendars to Display")
            }
        }
        .alert("Please select at least one calendar to show.", isPresented: $selectACalendarAlert) {
            Button("Okay", role: .cancel, action: {})
        }
        
        Button("Done") {
            
            let count = calendarSet.appleCalendars.filter({$0.isSelected}).count
            if count > 0 {
                calendarSet.saveUserCalendars()
                dismiss()
            } else {
                selectACalendarAlert = true
            }
        }
        .buttonStyle(.borderedProminent)
    }
    
}




