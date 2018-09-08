//
//  ScheduleDataProviderDelegateSpy.swift
//  ScheduleSelectorTests
//
//  Created by Mendoza, Christine Roanne
//  Copyright © 2018 Mendoza, Christine Roanne. All rights reserved.
//

import Foundation

class ScheduleDataProviderDelegateSpy: ScheduleDataProviderDelegate {
    
    var updatedDateReceived: String?
    var updatedTimeReceived: String?
    var dataFetchDidFailWasCalled = false
    
    func didUpdateSelection(date: String, time: String) {
        updatedDateReceived = date
        updatedTimeReceived = time
    }
    
    func dataFetchDidFail() {
        dataFetchDidFailWasCalled = true
    }
}
