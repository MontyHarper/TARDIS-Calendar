//
//  LocationManagerDelegate.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 10/8/23.
//

import CoreLocation
import Foundation

class LocationManagerDelegate:NSObject, CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // This method is called when the location manager is initialized.
        // Check whether authorization is determined. If not, get permission.
        if manager.authorizationStatus == .notDetermined {
            // get permission
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // if location changes while the app is in use, the appropriate constants should change.
        // this includes the user's location as well as all the solar data for the day
    }
}
