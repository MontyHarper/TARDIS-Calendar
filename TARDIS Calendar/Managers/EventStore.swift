//
//  CalendarPermission.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 1/23/24.
//
//  This is a singleton class containing an event store that can be used throughout the app as needed.
//

import EventKit
import Foundation

class EventStore {
    
    static var shared = EventStore()

    let store = EKEventStore()
    
    private init() {
    }
    
    var permissionIsGiven: Bool {
        EKEventStore.authorizationStatus(for: .event) == .authorized
    }
    
    func requestPermission(completion: @escaping () -> Void) {
        
        // The purpose of this method is to trigger a request for permission when user first starts up the app. We don't need the result here. If permission status changes, the permissionIsGiven bool will automatically change values, and Notification Center will trigger a new update.
        
        // Ask permission the new way if available
#if swift(>=5.9)
        if #available(iOS 17.0, *) {
            store.requestFullAccessToEvents { _, _ in
                completion()
            }
            
        } else {
            // Ask permission the old way if not
            store.requestAccess(to: EKEntityType.event) { _, _ in
                completion()
            }
        }
        
#else
        store.requestAccess(to: EKEntityType.event) { _, _ in
            completion()
        }
        
#endif
    }
}
