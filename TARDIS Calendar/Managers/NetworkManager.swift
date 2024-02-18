//
//  NetworkManager.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 2/14/24.
//

import Foundation
import Network

// This is a very generic manager with a fetch data function that will work for any type of data coming in from any URL request.

class NetworkManager {
    
    private let session = URLSession.shared
    
    func fetchData<T: Decodable>(by url: URL, completion: @escaping ((T?) -> Void)) {
        
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request) { data, response, error in
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let results = try decoder.decode(T.self, from: data)
                completion(results)
            } catch {
                completion(nil)
                return
            }
        }
        task.resume()
    }
}


// Here are the specific URLs for the network tasks this app will actually use.

extension NetworkManager {
    
    // SunriseSunset API
    
    var solarDayUrlBase: String {  "https://api.sunrisesunset.io/"
    }
    
    func solarDayURL(longitude: Double, latitude: Double, formattedDate: String) -> URL {
        
        let urlString = solarDayUrlBase + "json?lat=" + String(latitude) + "&lng=" + String(longitude) + "&date=" + formattedDate
        return URL(string: urlString)!
    }
    
    func fetchSolarDay(longitude: Double, latitude: Double, formattedDate: String, completion: @escaping (SolarDay?) -> Void) {
                
        let urlForRequest = URL(string: (solarDayUrlBase + "json?lat=" + String(latitude) + "&lng=" + String(longitude) + "&date=" + formattedDate))!
        
        fetchData(by: urlForRequest) { (solarDay: SolarDay?) in
            completion(solarDay)
        }
    }
}
