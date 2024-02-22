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
    @State private var stateBools = StateBools.shared
    @EnvironmentObject var size: Dimensions
    var formatter = RelativeDateTimeFormatter()
    let dateWentDown = UserDefaults.standard.object(forKey: UserDefaultKey.DateInternetWentDown.rawValue) as? Date ?? Date()
    
    var body: some View {
                
        ZStack {
            
            // Shows a warning message which can then be tapped for more information.
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
            let alert = "To display events, please allow this app to access your Apple Calendar.\n\nFind TARDIS Calendar in your Settings App and change the permissions."
            return (warning: warning, alert: alert)
        }
        
        if stateBools.noCalendarsAvailable {
            let warning = "This Calendar Is Empty"
            let alert = "To display events, please make sure your Apple Calendars App is installed and up to date."
            return (warning: warning, alert: alert)
        }
        
        if stateBools.noCalendarsSelected {
            let warning = "This Calendar Is Empty."
            let alert = "To display events, please tripple-tap the upper right hand corner to open Settings, go to \"Choose Calendars,\" and turn on the calendars you want to display. Make sure to also select a type for each calendar."
            return (warning: warning, alert: alert)
        }
        
        if stateBools.internetIsDown {
            let warning = "Check Internet Connection."
            let alert = "Your internet connection has been down since: \n\n\(formatter.localizedString(for: dateWentDown, relativeTo: Date()))\n\nYour calendar may be missing recent information. \n\nPlease let a helper know."
            return (warning: warning, alert: alert)
        }
        
        if !stateBools.authorizedForLocationAccess {
            let warning = "Day and Night Are Not Showing Correctly."
            let alert = "Permission is needed to access your general location. This will allow sunrise and sunset times to display correctly in the background.\n\nPlease find TARDIS Calendar in your Settings App and change the permissions."
            return (warning: warning, alert: alert)
        }
        
        if stateBools.showMissingSolarDaysWarning {
            let warning = "Day and Night Are Not Showing Correctly."
            let alert = "It has been \(stateBools.missingSolarDays) days since you've been able to access sunrise and sunset information. Times depicted in the background are no longer accurate.\n\nYour internet connection seems to be good, and your permissions are set correctly, so there's nothing you can do but hope it goes away.\n\nPlease report this to monty@montyharper.com."
            return (warning: warning, alert: alert)
        }
        
        // Default Warning. This should never be needed.
        return (warning: "", alert: "")
    }
    
}
