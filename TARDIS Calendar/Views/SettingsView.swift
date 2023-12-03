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
    
    
    @StateObject var eventManager: EventManager
    @State private var showWelcome = StateBools.shared.newUser && StateBools.shared.noCalendarsSelected
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        VStack {
            Text("Settings")
                .font(.largeTitle)
            
            NavigationView {
                
                if eventManager.calendarSet.appleCalendars.count > 0 {
                    // Lists all calendars present in the user's Apple Calendar App.
                    List($eventManager.calendarSet.appleCalendars) {$calendar in
                        HStack {
                            // Use toggles to mark which calendars this app will display events from.
                            Toggle("Use this calendar", isOn: $calendar.isSelected)
                                .labelsHidden()
                                .padding()
                                .background(.white)
                            Text("    \"\(calendar.title)\"" + (calendar.isSelected ? " - Display as:" : ""))
                            // Attatches a calendar type to each calendar
                            if calendar.isSelected {
                                Picker("Select a type:", selection: $calendar.type) {
                                    ForEach(CalendarType.allCases) {type in
                                        Text(type.rawValue)
                                    }
                                }
                                .labelsHidden() // Needed to do this to control the spacing between label and options; otherwise there's a huge gap!
                            }
                            Spacer()
                        }
                        .background(calendar.color)
                        
                    } // End of calendars list
                    .navigationTitle("Choose Calendars to Display")
                    
                } else if StateBools.shared.noPermissionForCalendar {
                    Text("This app displays events from the Apple Calendar App.\n\nYour permission is needed to access those events.\n\nLook for TARDIS Calendar in your Settings app to change permissions.")
                }
                
            } // End of NavigationView
              // TODO: - Update this to the newer version of alert.
            .alert("Welcome to TARDIS Calendar!\n\nThis app shows events from the Apple Calendar App. To connect with Apple Calendar, please choose which calendars to show events from.\n\nYou can return to this page by tripple-tapping in the upper right hand corner of the screen.", isPresented: $showWelcome) {
                Button("OK", role: .cancel, action: {})
            }
            .onAppear {
                print("Number of calendars to choose from: ", eventManager.calendarSet.appleCalendars.count)
            }
            
            Button("Done") {
                
                let count = eventManager.calendarSet.appleCalendars.filter({$0.isSelected}).count
                if count > 0 {
                    // Saves these settings to UserDefaults
                    eventManager.calendarSet.saveUserCalendars()
                }
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
    
    
