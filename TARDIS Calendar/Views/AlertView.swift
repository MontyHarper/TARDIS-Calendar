//
//  AlertViews.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 11/28/23.
//

import Foundation
import SwiftUI


struct AlertView: View {
    
    // TODO: - I believe this kind of alert is deprecated, and this View could be updated to take advantage of the newer version of .alert which includes a title, details, and a built-in dismiss button. https://developer.apple.com/documentation/swiftui/view/alert(_:ispresented:presenting:actions:message:)-8584l
    @State private var showAlert = false
    @EnvironmentObject var stateBools: StateBools
    @EnvironmentObject var size: Dimensions
    var formatter = RelativeDateTimeFormatter()
    let dateWentDown = UserDefaults.standard.object(forKey: "lastTimeInternetWentDown") as? Date ?? Date()
    
    var body: some View {
                
        ZStack {
            
            // Alert for lost network connection.
            if stateBools.showWarning {
                
                Text(showText().0)
                    .foregroundColor(.red)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .position(x: size.width * 0.5, y: size.height * 0.95)
                    .onTapGesture {showAlert = true}
                    .alert(showText().1, isPresented: $showAlert) {
                        Button("OK", role: .cancel, action: {})
                    }
                    .font(.system(size: size.fontSizeMedium, weight: .bold))
                    .onAppear {
                        formatter.unitsStyle = .spellOut
                        formatter.dateTimeStyle = .named
                    }
            } // End network connection alert.
            
        } // End of ZStack.
        
    }
    
    // Provides a hierarchy: only one warning is shown at a time; each takes priority over the warnings below.
    func showText() -> (warning: String, alert: String) {
        
        if stateBools.noPermissionForCalendar {
            let warning = "This Calendar Is Empty"
            let alert = "To display events, please give permission to access your Apple Calendar App.\n\nFind TARDIS Calendar in your Settings App and change the permissions."
            return (warning: warning, alert: alert)
        }
        
        if stateBools.noCalendarsAvailable {
            let warning = "This Calendar Is Empty"
            let alert = "To display events, please set up one or more calendars to display in your Apple Calendars App."
            return (warning: warning, alert: alert)
        }
        
        if stateBools.noCalendarsSelected {
            let warning = "This Calendar Is Empty."
            let alert = "To display events, please select one or more calendars from your Apple Calendars App.\n\nTripple tap the upper right hand corner to open Settings and select calendars."
            return (warning: warning, alert: alert)
        }
        
        if stateBools.internetIsDown {
            let warning = "Check Internet Connection."
            let alert = "Your internet connection has been down since: \n\n\(formatter.localizedString(for: dateWentDown, relativeTo: Date()))\n\nYour calendar may be missing recent information. \n\nPlease let a helper know."
            return (warning: warning, alert: alert)
        }
        
        if !stateBools.authorizedForLocationAccess {
            let warning = "Day and Night Are Not Showing Correctly."
            let alert = "Sunrise and sunsets are depicted with colors in the background. To show them at correct times, permission is needed to access your general location.\n\nPlease find TARDIS Calendar in your Settings App and change the permissions."
            return (warning: warning, alert: alert)
        }
        
        
        if stateBools.showMissingSolarDaysWarning {
            let warning = "Day and Night Are Not Showing Correctly."
            let alert = "It has been \(stateBools.missingSolarDays) days since you've been able to access sunrise and sunset information. Times depicted in the background are no longer accurate. Sorry, but we don't know why this is happening."
            return (warning: warning, alert: alert)
        }
        
        // Default Warning. This should never be needed.
        return (warning: "Something is wrong.", alert: "Some error is causing this message. It isn't your fault! Let Monty know.")
    }
    
}
