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
    
    @EnvironmentObject var eventManager: EventManager
    @Environment(\.dimensions) private var dimensions
    @State private var stateBools = StateBools.shared
    @State private var showWelcome = false
    @State private var iconPhoto: PhotosPickerItem?
    @Environment(\.dismiss) var dismiss
    
    
    var body: some View {
        
        NavigationView {
            Form {
                NavigationLink("Choose Calendars", destination: calendarSelectionView)
                    .font(.title)
                
                NavigationLink("Change Now Icon", destination: photoSelectionView)
                    .font(.title)
                
            } // End of Form
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button("Done") {
                        eventManager.saveUserCalendars()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        } // End of NavigationView
        .onAppear {
            showWelcome = stateBools.newUser && stateBools.noCalendarsSelected
        }
        
        // Welcome message for a new user...
        // TODO: - Update this to the newer version of alert, once you can upgrade your computer.
        .alert("Welcome to TARDIS Calendar!\n\nPlease select \"Choose Calendars\" to mark which Apple calendars you want to display.\n\nYou can always return to this page by tripple-tapping the upper-right-hand corner of the screen.", isPresented: $showWelcome) {
            Button("OK", role: .cancel, action: {})
        }
    } // End body
    
    
    @ViewBuilder var calendarSelectionView: some View {
        
        if !eventManager.appleCalendars.isEmpty {
            
            // Lists all calendars present in the user's Apple Calendar App.
            List($eventManager.appleCalendars) {$calendar in
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
            
            
        } else if !EventStore.shared.permissionIsGiven {
            
            
            ScrollView {
                Text("Calendars Cannot Be Listed")
                    .font(.title)
                Text("\nYou have not given permission for this app to access your Apple Calendars App. The TARDIS app can only display events from your Apple Calendar App. Without permission to access those events, your TARDIS Calendar will have nothing to display.\n\n Please find TARDIS Calendar in your Settings app and switch \"Calendars\" to ON.")
            }
            .padding()
            
        } else {
            Text("Something's wrong.")
                .task {
                    print("why are no calendars listed?")
                    print("Permission given: ", EventStore.shared.permissionIsGiven)
                    print("Calendars empty: ", eventManager.appleCalendars.isEmpty)
                }
        }
    } // End of calendarSelectionView
    
    
    @ViewBuilder var photoSelectionView: some View {
        
        VStack {
            
            Spacer()
            Text("Now Icon")
                .dynamicTypeSize(.xxxLarge)
                .fontWeight(.black)
            ZStack {
                Circle()
                    .frame(width: dimensions.mediumEvent, height: dimensions.mediumEvent).foregroundColor(.blue)
                    .zIndex(9)
                    .shadow(color: .white, radius: dimensions.mediumEvent * 0.1)
                NowView.nowIcon
                    .resizable()
                    .aspectRatio(contentMode:.fit)
                    .frame(width:dimensions.mediumEvent * 0.9, height: dimensions.mediumEvent * 0.9, alignment:.center)
                    .clipShape(Circle())
                    .zIndex(10)
            }
            Toggle("Use Default: ", isOn: $stateBools.useDefaultNowIcon)
            Spacer()
                
            // TODO: - Here is where I need to learn more to make this photo thing happen. See project notes.
            if !stateBools.useDefaultNowIcon {
                PhotosPicker("Choose a New Photo", selection: $iconPhoto, matching: .images)
                    .onChange(of: iconPhoto) { _ in
                        // A PhotosPicker item cannot be persisted as a UserDefault (plist) item. I will need to use a different method here.
//                        if let photo = iconPhoto {
//                            UserDefaults.standard.set(Image(photo), forKey: "nowIcon")
//                        }
                    }
            }
            Spacer()
                        
        } // End of VStack
        .frame(maxWidth: dimensions.mediumEvent)
        
    } // End of photoSelectionView
    
} // End of SettingsView







