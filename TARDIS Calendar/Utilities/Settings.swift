//
//  Settings.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 10/7/23.
//
//  Singleton for storing certain default values and settings.
//  Many of these have been replaced by the timeline class.
//  However, some may still be useful...
//  TODO: - Clean up settings; what can I use, what do I not need any more?
//

import Foundation
import CoreLocation
import SwiftUI

// My thought is that the timeline settings are best set in timeline and can probably be deleted from here.
// Then use this to provide defaults for when user settings haven't been set up (now image, lat and long)
// And for other values that I may want to tweak or provide to users to set in the future.

class Settings {
    
    static let shared = Settings()
    
    let maxFutureDays: Int
    let hoursOnScreen: Double
    let nowLocation: Double
    let userImage: Image
    let calendar: Calendar
    let latitude: Double
    let longitude: Double
    // let locationManager: CLLocationManager
    
    /*
     User-settable parameters for the app.
     For now these values are set here, but they should become accessible to users at some point.
     In the meantime it's convenient for me to play with changes from here.
     */

   private init() {
       maxFutureDays = 14 // Number of days into the future the calendar can display.
       hoursOnScreen = 4 // Number of hours to show on screen when calendar reverts to default mode.
       nowLocation = 0.2  // Percentage of the screen to the left of now.
       userImage = Image(systemName:"person.circle.fill") // Sets an image to use for the Now icon
       calendar = Calendar.autoupdatingCurrent // Sets the app's calendar to the user's chosen calendar for the device.
       latitude = 36.110170
       longitude = -97.058570
       // locationManager tracks the user's location in order to deliver accurate sunrise and sunset times.
       // let locationManager = CLLocationManager()
       // locationManager.delegate = LocationManagerDelegate
       // locationManager.desiredAccuracy = kCLLocationAccuracyReduced
       
       // The location manager tracks the user's location for accurate representation of sunrise and sunset.
       
   }
}
