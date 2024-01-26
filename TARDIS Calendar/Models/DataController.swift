//
//  DataController.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 11/26/23.
//

import CoreData
import Foundation

class DataController: ObservableObject {
    
    let container = NSPersistentContainer(name: "StoredSolarDays")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load. Error: \(error.localizedDescription)")
            }
        }
    }
}
