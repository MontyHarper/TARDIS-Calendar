//
//  SolarEvents.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 10/12/23.
//

import Foundation

class SolarEventManager: ObservableObject {
    
    @Published var solarDays: [SolarDay] = []
    var newSolarDays: [SolarDay] = []
    // recursive function to make the network requests
    // closure calls the next request.
    // that way each element in the array is filled before the next is attempted
    // if a request fails you can fill in values from the previous element
    // unless it's the first in which case fill in default values
    
    init() {
        updateSolarDays()
    }
    
    func updateSolarDays() {
        let startDate = Timeline.calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date()) ?? Date()
        let endDate = Timeline.calendar.date(byAdding: .day, value: Timeline.maxFutureDays + 1, to: startDate) ?? Date(timeIntervalSince1970: (Date().timeIntervalSince1970 + Double(Timeline.maxFutureDays * 60 * 60 * 24)))
        let date = startDate
        
        fetchSolarDay(date: date, endDate: endDate)
    }
    
    // At the moment this is a hodgepodge of copied over lines from the virtual tourist.
    // I need to change out the details so they work with this app of course, and shore up the flow...
    func fetchSolarDay(date: Date, endDate: Date) {
        
        // set up the fetch
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let formattedDate = formatter.string(from: date)
        let urlString = "https://api.sunrisesunset.io/json?lat=" + String(Settings.shared.latitude) + "&lng=" + String(Settings.shared.longitude) + "&date=" + formattedDate
        print("searching with this URL: \(urlString)")
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        let session = URLSession.shared
        
        // call the fetch
        let task = session.dataTask(with: request) { data, response, error in
            
            // If data is returned,
            if let data = data {
                
                // add results to the array of solar events
                
                let decoder = JSONDecoder()
                do {
                    let results = try decoder.decode(Results.self, from: data)
                    let solarDay = results.results
                    print("fetched solar day for \(formattedDate): \(solarDay) ")
                    // Success!
                    // Save data
                    self.newSolarDays.append(solarDay)
                    
                } catch {
                    print("The data doesn't fit our response pattern")
                }
                
                let nextDate = Timeline.calendar.date(byAdding: .day, value: 1, to: date) ?? Date(timeIntervalSince1970: (Date().timeIntervalSince1970 + Double(60 * 60 * 24)))
                if nextDate < endDate {
                    self.fetchSolarDay(date: nextDate, endDate: endDate)
                } else {
                    DispatchQueue.main.async {
                        self.solarDays = self.newSolarDays
                        self.newSolarDays = []
                    }
                }
            }
        }
        task.resume()
    }
}
