//
//  LocationManagerDelegate.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 10/8/23.
//
//  This class is a delegate/facade for CLLocationManager.
//  It requires its own delegate to pass information to.
//  It simplifies the change in authorization to a Bool.
//  It simplifies the change in location to a single latitude & longitude and only if the change is significant.
//


import CoreLocation
import Foundation

class LocationManager: NSObject, CLLocationManagerDelegate {

    private var manager = CLLocationManager()
    var currentLatitude: Double?
    var currentLongitude: Double?
    
    var delegate: LocationUpdateReceiver?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        // The following requests a location to start off with, which will be processed through the didUpdateLocation method below.
        // SignificantLocationChange means 500 meters or more.
        manager.startMonitoringSignificantLocationChanges()
    }
    
    // Necessary to keep the app from launching if location changes while app is inactive.
    deinit {
        manager.stopMonitoringSignificantLocationChanges()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        var response: Bool
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            response = true
        default:
            response = false
        }
        print("Authorization Changed: \(manager.authorizationStatus)")
        if let delegate = delegate {
            delegate.receiveAuthorizationStatusChange(authorized: response)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations[locations.count - 1]
        let newLongitude = newLocation.coordinate.longitude
        let newLatitude = newLocation.coordinate.latitude
        currentLatitude = newLatitude
        currentLongitude = newLongitude
        if let delegate = delegate {
            delegate.receiveLocationUpdate(latitude: newLatitude, longitude: newLongitude)
        }
    }
    
    // TODO: - handle these possible errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location manager failed with error: \(error)")
    }
}

// Allows for a delegate to receive notification of a new location.
protocol LocationUpdateReceiver {
    func receiveLocationUpdate(latitude: Double, longitude: Double)
    func receiveAuthorizationStatusChange(authorized: Bool)
}
