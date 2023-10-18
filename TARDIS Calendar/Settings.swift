//
//  Settings.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 10/7/23.
//

import Foundation
import CoreLocation
import SwiftUI

class Settings {
    
    static let shared = Settings()
    
    let maxFutureDays: Int
    let hoursOnScreen: Double
    let nowLocation: Double
    let userImage: Image
    let calendar: Calendar
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
       userImage = Image("Mom") // Sets an image to use for the Now icon
       calendar = Calendar.autoupdatingCurrent // Sets the app's calendar to the user's chosen calendar for the device.
       // locationManager tracks the user's location in order to deliver accurate sunrise and sunset times.
       // let locationManager = CLLocationManager()
       // locationManager.delegate = LocationManagerDelegate
       // locationManager.desiredAccuracy = kCLLocationAccuracyReduced
       
       // The location manager tracks the user's location for accurate representation of sunrise and sunset.
       
   }
}
