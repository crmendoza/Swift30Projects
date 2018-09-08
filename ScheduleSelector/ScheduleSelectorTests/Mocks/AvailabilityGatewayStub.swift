//
//  AvailabilityGatewayStub.swift
//  ScheduleSelectorTests
//
//  Created by Mendoza, Christine Roanne
//  Copyright © 2018 Mendoza, Christine Roanne. All rights reserved.
//

import Foundation

class AvailabilityGatewayStub: NetworkGateway {
    var availabilitiesToReturn: [Schedule]?
    
    func fetchData(completion: @escaping ([Schedule]?) -> Void) {
        completion(availabilitiesToReturn)
    }
}
