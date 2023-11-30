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
    private let networkMonitor = NWPathMonitor()
    private let workerQueue = DispatchQueue(label: "Monitor")
    
    // "internetWasDown" saves the previous state of connection so it will persist across the app being inactive, so we can let the user know how long since information could have been updated.
    // Necessary because every time the app starts, the current connection status is registered as a change, even if it hasn't really changed.
    var internetWasDown: Bool {
        UserDefaults.standard.bool(forKey: "internetWasDown")
    }
    var internetIsDown = true

    init() {
        networkMonitor.pathUpdateHandler = { path in
            self.internetIsDown = !(path.status == .satisfied)
            // If the connection is down and it was not down before, reset the time it went down.
            if self.internetIsDown && !self.internetWasDown {
                UserDefaults.standard.set(Date(), forKey: "lastTimeInternetWentDown")
            }
            UserDefaults.standard.set(self.internetIsDown, forKey: "internetWasDown")
            Task {
                await MainActor.run {
                    self.objectWillChange.send()
                }
            }
        }
        networkMonitor.start(queue: workerQueue)
    }
}
