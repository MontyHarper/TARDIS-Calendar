//
//  NetworkManager.swift
//  TARDIS Calendar
//
//  Created by Monty Harper on 2/14/24.
//

import Foundation
import Network

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


// Specific URLs for network tasks

extension NetworkManager {
    
    // SunriseSunset API
    
    var solarDayUrlBase: String {  "https://api.sunrisesunset.io/"
    }
    
    func solarDayURL(longitude: Double, latitude: Double, formattedDate: String) -> URL? {
        
        let urlString = solarDayUrlBase + "json?lat=" + String(latitude) + "&lng=" + String(longitude) + "&date=" + formattedDate
        return URL(string: urlString)
    }
}
