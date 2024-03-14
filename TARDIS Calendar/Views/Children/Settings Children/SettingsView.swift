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
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.dimensions) var dimensions
    
    @EnvironmentObject var eventManager: EventManager
    
    @State var welcomeIsVisible = false
    @State private var iconPhoto: PhotosPickerItem?

    
    var body: some View {
        
        NavigationStack {
            Form {
                NavigationLink("Choose Calendars", destination: CalendarSelectionView(calendars: $eventManager.appleCalendars))
                    .font(.title)
                
                NavigationLink("Change Now Icon", destination: PhotoSelectionView())
                    .font(.title)
            } // End of Form
            .navigationTitle("Settings")
            .interactiveDismissDisabled()
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button("Done") {
                        eventManager.updateEverything()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        } // End of NavigationView
        
        // Welcome message for a new user...
        // TODO: - Update this to the newer version of alert, once you can upgrade your computer.
        .alert("Welcome to TARDIS Calendar!\n\nPlease select \"Choose Calendars\" to mark which Apple calendars you want to display.\n\nYou can always return to this page by tripple-tapping the upper-right-hand corner of the screen.", isPresented: $welcomeIsVisible) {
            Button("OK", role: .cancel) {
                UserDefaults.standard.set(true, forKey: UserDefaultKey.AppHasBeenLaunchedBefore.rawValue)
            }
        }
    } // End body
} // End of View
    
    
    
    
    








