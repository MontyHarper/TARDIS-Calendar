//
//  NetworkMonitor.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 11/29/23.
//
//  So that I can check the network connection as needed.
//  Thanks to Danijela Vrzan for the basis for this code: https://www.danijelavrzan.com/posts/2022/11/network-connection-alert-swiftui/
//  I added functionality to track how long the connection has been down.
//


import Foundation
import Network

class NetworkMonitor: ObservableObject {
    
    static var internetIsDown = true
    
    private let networkMonitor = NWPathMonitor()
    private let workerQueue = DispatchQueue(label: "Monitor")
    
    // "internetWasDown" saves the previous state of connection so it will persist when the app is inactive, so we can let the user know how long information has not been updated.
    // Necessary because every time the app starts, the current connection status is registered as a change, even if it hasn't really changed.
    private var internetWasDown: Bool {
        UserDefaults.standard.bool(forKey: UserDefaultKey.InternetWasDown.rawValue)
    }


    init() {
        networkMonitor.pathUpdateHandler = { path in
            NetworkMonitor.internetIsDown = (path.status != .satisfied)
            // If the connection is down and it was not down before, reset the time it went down.
            if NetworkMonitor.internetIsDown && self.internetWasDown == false {
                UserDefaults.standard.set(Date(), forKey: UserDefaultKey.DateInternetWentDown.rawValue)
            }
            UserDefaults.standard.set(NetworkMonitor.internetIsDown, forKey: UserDefaultKey.InternetWasDown.rawValue)
            Task {
                await MainActor.run {
                    self.objectWillChange.send()
                }
            }
        }
        networkMonitor.start(queue: workerQueue)
    }
}
