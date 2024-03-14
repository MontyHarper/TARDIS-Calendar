//
//  CalendarSelectionView.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 3/11/24.
//

import SwiftUI

struct CalendarSelectionView: View {
    
    @Binding var calendars: [AppleCalendar]
    
    
    var body: some View {
        
        if !calendars.isEmpty {
            
            // Lists all calendars present in the user's Apple Calendar App.
            List($calendars) {$calendar in
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
            
            
        }
        else if !EventStore.shared.permissionIsGiven {


            ScrollView {
                Text("Calendars Cannot Be Listed")
                    .font(.title)
                Text("\nYou have not given permission for this app to access your Apple Calendars App. The TARDIS app can only display events from your Apple Calendar App. Without permission to access those events, your TARDIS Calendar will have nothing to display.\n\n Please find TARDIS Calendar in your Settings app and switch \"Calendars\" to ON.")
            }
            .padding()

        } else {
            Text("Something's wrong.")
                .onAppear {
                    print("why are no calendars listed?")
                    print("Permission given: ", EventStore.shared.permissionIsGiven)
                    print("Calendars empty: ", calendars.isEmpty)
                }
        }
    }
}


