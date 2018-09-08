//
//  AvailabilityGateway.swift
//  ScheduleSelector
//
//  Created by Mendoza, Christine Roanne
//  Copyright © 2018 Mendoza, Christine Roanne. All rights reserved.
//

import Foundation

protocol NetworkGateway {
    func fetchData(completion: @escaping ([Schedule]?) -> Void)
}

class AvailabilityGateway: NetworkGateway {
    let availabilityURL = "https://api.myjson.com/bins/rm23h"
    
    func fetchData(completion: @escaping ([Schedule]?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            if let url = URL(string: self.availabilityURL) {
                let task = URLSession.shared.dataTask(with: url, completionHandler: { (JSONData, response, error) in
                    if error != nil {
                        completion(nil)
                    } else {
                        guard let JSONData = JSONData else {
                            completion(nil)
                            return
                        }
                        do {
                            let data = try JSONDecoder().decode([String: [Schedule]].self, from: JSONData)
                            guard let availabilities = data["availabilities"] else {
                                completion(nil)
                                return
                            }
                            completion(availabilities)
                        } catch {
                            completion(nil)
                        }
                    }
                })
                task.resume()
            }
        }
    }
}

