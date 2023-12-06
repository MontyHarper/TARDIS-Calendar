//
//  LocationManagerDelegate.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 10/8/23.
//
//  To be honest, I do not understand the need for this.
//  But if I comment it out I get a buttload of errors.
//  TODO: - Can I combine this with the Location Manager stuff in SolarEventManager, either here or there?
//

import CoreLocation
import Foundation

class LocationManager: NSObject, CLLocationManagerDelegate {

    private var manager = CLLocationManager()
    private var stateBools = StateBools.shared
    private var defaults = UserDefaults.standard
    var delegate: LocationUpdateReceiver?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startMonitoringSignificantLocationChanges()
    }
    
    deinit {
        manager.stopMonitoringSignificantLocationChanges()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            stateBools.noPermissionForLocation = false
        default:
            stateBools.noPermissionForLocation = true
        }
        print("Authorization Changed: \(manager.authorizationStatus)")
    }
    
    // This gets called when permissions change and at each launch, and also for some reason my location here at my desk seems to be changing slightly every time I launch the app??? - so we need to check whether location actually changed significantly from the last known location before updating any state.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations[locations.count - 1]
        let newLongitude = newLocation.coordinate.longitude
        let newLatitude = newLocation.coordinate.latitude
        let oldLongitude = defaults.double(forKey: "longitude")
        let oldLatitude = defaults.double(forKey: "latitude")
        
        if abs(oldLatitude - newLatitude) > 0.1 || abs(oldLongitude - newLongitude) > 0.1 {
            defaults.set(newLongitude,forKey:"longitude")
            defaults.set(newLatitude,forKey:"latitude")
            if let delegate = delegate {
                delegate.receiveLocationUpdate()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location manager failed with error: \(error)")
    }
}

// My own delegate pattern for sending updates to the solarEventManager.
protocol LocationUpdateReceiver {
    func receiveLocationUpdate()
}
