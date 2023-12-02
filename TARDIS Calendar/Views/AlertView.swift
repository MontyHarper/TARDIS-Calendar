//
//  AlertViews.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 11/28/23.
//

import Foundation
import SwiftUI


struct AlertView: View {
    
    @State private var showAlert = false
    @StateObject var stateBools = StateBools.shared
    var screen: GeometryProxy
    var formatter = RelativeDateTimeFormatter()
    let dateWentDown = UserDefaults.standard.object(forKey: "lastTimeInternetWentDown") as? Date ?? Date()
    
    var body: some View {
                
        ZStack {
            
            // Alert for lost network connection.
            if stateBools.showWarning {
                
                Text(showText().0)
                    .foregroundColor(.red)
                    .fontWeight(.bold)
                    .position(x: screen.size.width * 0.75, y: screen.size.height * 0.9)
                    .onTapGesture {showAlert = true}
                    .alert(showText().1, isPresented: $showAlert) {
                        Button("OK", role: .cancel, action: {})
                    }
                    .onAppear {
                        formatter.unitsStyle = .spellOut
                        formatter.dateTimeStyle = .named
                    }
            } // End network connection alert.
            
            // Alert to show network activity.
            if stateBools.showLoadingBackground {
                
                Text("Loading Background...")
                    .foregroundColor(.red)
                    .position(x: screen.size.width * 0.5, y: screen.size.height * 0.85)
            }
            
        } // End of ZStack.
        
    }
    
    // Provides a hierarchy: only one warning is shown at a time; each takes priority over the warnings below.
    func showText() -> (warning: String, alert: String) {
        
        if stateBools.noPermissionForCalendar {
            let warning = "This Calendar Is Empty"
            let alert = "In order for this calendar to show events, it needs permission to access your Apple Calendar App.\n\nPlease let a helper know.\n\nThis can be fixed by finding TARDIS Calendar in your Settings App and changing the permissions."
            return (warning: warning, alert: alert)
        }
        
        if stateBools.noCalendarsSelected {
            let warning = "This Calendar Is Empty."
            let alert = "To display events from the Apple Calendar App, you need to select which calendars to display.\n\nPlease let a helper know.\n\nTripple tap the upper right hand corner to open Settings and select calendars."
            return (warning: warning, alert: alert)
        }
        
        if stateBools.internetIsDown {
            let warning = "Check Internet Connection."
            let alert = "Your internet connection has been down since: \n\n\(formatter.localizedString(for: dateWentDown, relativeTo: Date()))\n\nYour calendar may be missing recent information. \n\nPlease let a helper know."
            return (warning: warning, alert: alert)
        }
        
        if stateBools.noPermissionForLocation {
            let warning = "Day and Night Are Not Showing Correctly."
            let alert = "Sunrise and sunset times are depicted with colors in the background. These times are currently shown as guesses.\n\nPlease let a helper know.\n\nThis can be fixed by finding TARDIS Calendar in your Settings App and changing the permissions."
            return (warning: warning, alert: alert)
        }
        
        return (warning: "Something is wrong.", alert: "Some error is causing this message. It isn't your fault! Let Monty know.")
    }
    
}
