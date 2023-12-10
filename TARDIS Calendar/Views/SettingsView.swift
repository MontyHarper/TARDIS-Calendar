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
import PhotosUI
import SwiftUI
import EventKit

struct SettingsView: View {
    
    @StateObject var eventManager: EventManager
    @State private var showWelcome = StateBools.shared.newUser && StateBools.shared.noCalendarsSelected
    @State private var iconPhoto: PhotosPickerItem?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        NavigationView {
            VStack {
                NavigationLink("Choose Calendars", destination: calendarSelectionView)
                    .font(.title)
                
                NavigationLink("Change Now Icon", destination: photoSelectionView)
                    .font(.title)
                
            } // End of VStack
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button("Done") {
                        eventManager.calendarSet.saveUserCalendars()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        } // End of NavigationView
        
        // Welcome message for a new user...
        // TODO: - Update this to the newer version of alert.
        .alert("Welcome to TARDIS Calendar!\n\nPlease select \"Choose Calendars\" to select which Apple calendars to display.\n\nYou can always return to this page by tripple-tapping the upper-right-hand corner of the screen.", isPresented: $showWelcome) {
            Button("OK", role: .cancel, action: {})
        }
    } // End body
    
    
    @ViewBuilder var calendarSelectionView: some View {
        
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
                        HStack {
                            Picker("Select a type:", selection: $calendar.type) {
                                ForEach(CalendarType.allCases) {type in
                                    Text(type.rawValue)
                                }
                            }
                            .labelsHidden() // Needed to do this to control the spacing between label and options; otherwise there's a huge gap!
                            if calendar.type == "none" {
                                Text("← Select a type.")
                            }
                        }
                    }
                    Spacer()
                } // End of row
                .background(calendar.color)
                
            } // End of calendars list
            .navigationTitle("Choose Calendars to Display")
            
            
        } else if StateBools.shared.noPermissionForCalendar {
            
            
            ScrollView {
                Text("Calendars Cannot Be Listed")
                    .font(.title)
                Text("\nYou have not given permission for this app to access your Apple Calendars App. The TARDIS app can only display events from your Apple Calendar App. Without permission to access those events, your TARDIS Calendar will have nothing to display.\n\n Please find TARDIS Calendar in your Settings app and switch \"Calendars\" to ON.")
            }
            .padding()
            
        }
    }
    
    @ViewBuilder var photoSelectionView: some View {
        HStack {
            
            VStack {
                Text("Current Now Icon")
                NowView()
            }
            
            Spacer()
            
            PhotosPicker("Choose a New Photo", selection: $iconPhoto, matching: .images)
                .onChange(of: iconPhoto) { _ in
                    print("photo changed")
                }
            
            Spacer()
        }
        .padding()
        
    }
}



    



