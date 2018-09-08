//
//  ScheduleDataProviderTests.swift
//  ScheduleSelectorTests
//
//  Created by Mendoza, Christine Roanne
//  Copyright © 2018 Mendoza, Christine Roanne. All rights reserved.
//

import XCTest

class ScheduleDataProviderTests: XCTestCase {
    
    var delegate: ScheduleDataProviderDelegateSpy!
    var gatewayMock: AvailabilityGatewayStub!
    var sut: ScheduleDataProvider!
    
    override func setUp() {
        super.setUp()
        
        delegate = ScheduleDataProviderDelegateSpy()
        gatewayMock = AvailabilityGatewayStub()
        sut = ScheduleDataProvider(delegate: delegate, gateway: gatewayMock)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        delegate = nil
        gatewayMock = nil
        sut = nil
        super.tearDown()
    }
    
    
    
    // MARK: Test helpers
    
    func createAvailabilities(dateCount: Int, timeslotCount: Int) -> [Schedule] {
        var schedules = [Schedule]()
        let status = [Status.available, Status.unavailable]
        
        for x in 0...dateCount {
            var timeslots = [Timeslot]()
            for _ in 0...timeslotCount {
                let slot = Timeslot(time: generateRandomDate(daysBack: x)!, availability: status[(Int(arc4random_uniform(2))-1)], duration: 90)
                timeslots.append(slot)
            }
            let schedule = Schedule(date: generateRandomDate(daysBack: x)!, timeslots: timeslots)
            schedules.append(schedule)
        }
        return schedules
    }
    
    // ref: https://gist.github.com/edmund-h/2638e87bdcc26e3ce9fffc0aede4bdad
    func generateRandomDate(daysBack: Int)-> Date?{
        let day = arc4random_uniform(UInt32(daysBack))+1
        let hour = arc4random_uniform(23)
        let minute = arc4random_uniform(59)
        
        let today = Date(timeIntervalSinceNow: 0)
        let gregorian  = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        var offsetComponents = DateComponents()
        offsetComponents.day = Int(day - 1)
        offsetComponents.hour = Int(hour)
        offsetComponents.minute = Int(minute)
        
        let randomDate = gregorian?.date(byAdding: offsetComponents, to: today, options: .init(rawValue: 0) )
        return randomDate
    }
}
