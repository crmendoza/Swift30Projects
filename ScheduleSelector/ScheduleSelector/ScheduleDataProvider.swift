//
//  ScheduleDataProvider.swift
//  ScheduleSelector
//
//  Created by Mendoza, Christine Roanne
//  Copyright © 2018 Mendoza, Christine Roanne. All rights reserved.
//

import Foundation
import UIKit

enum DateFormat: String {
    case date = "MMMdd日 (E)"
    case time = "HH:mm"
}

protocol ScheduleDataProviderDelegate: class {
    func didUpdateSelection(date: String, time: String)
    func dataFetchDidFail()
}

class ScheduleDataProvider {
    
    var selectedTimeslot: Date? {
        didSet {
            if let date = selectedTimeslot?.stringWithFormat(format: DateFormat.date.rawValue), let time = selectedTimeslot?.stringWithFormat(format: DateFormat.time.rawValue) {
                self.delegate?.didUpdateSelection(date: date, time: time)
            }
        }
    }
    
    var availabilitySchedules: [Schedule]!
    let gateway: NetworkGateway
    weak var delegate: ScheduleDataProviderDelegate?
    
    init(delegate: ScheduleDataProviderDelegate, gateway: NetworkGateway) {
        self.delegate = delegate
        self.gateway = gateway
    }
    
    // MARK: Data fetch
    
    func fetchData() {
        self.gateway.fetchData(completion: { (availabilities) in
            if availabilities != nil {
                self.availabilitySchedules = availabilities!
                if let defaultSchedule = self.availabilitySchedules.first {
                    self.selectedTimeslot = defaultSchedule.timeslots.filter { $0.availability == .available }.first?.time
                }
            } else {
                self.delegate?.dataFetchDidFail()
            }
        })
    }
    
    // MARK: Datasource
    
    func numberOfTimeslotForSelectedSchedule() -> Int {
        let currentSchedule = availabilitySchedules[indexOfSelectedDate()]
        return currentSchedule.timeslots.count
    }
    
    func numberOfSchedules() -> Int {
        return availabilitySchedules.count
    }
    
    func stringForDateAtIndex(index: Int) -> NSAttributedString? {
        if index < availabilitySchedules.count {
            let currentSchedule = availabilitySchedules[index]
            return NSAttributedString.init(string: currentSchedule.date.stringWithFormat(format: DateFormat.date.rawValue))
        }
        
        return nil
    }
    
    func stringForTimeslotAtIndex(index: Int) -> NSAttributedString? {
        let schedule = availabilitySchedules[indexOfSelectedDate()]
        if index < schedule.timeslots.count {
            let timeslot = schedule.timeslots[index]
            let textColor = timeslot.availability == .available ? UIColor.black : UIColor.lightGray
            return NSAttributedString.init(string: timeslot.time.stringWithFormat(format: DateFormat.time.rawValue), attributes: [NSAttributedStringKey.foregroundColor : textColor])
        }
        
        return nil
    }
    
    func indexOfSelectedDate() -> Int {
        if let index = availabilitySchedules.index(where: { (schedule) -> Bool in
            NSCalendar.current.compare(schedule.date, to: self.selectedTimeslot!, toGranularity: Calendar.Component.day) == .orderedSame
        }) {
            if index < availabilitySchedules.count {
                return index
            }
        }
        
        return 0
    }
    
    func indexOfSelectedTimeslot() -> Int {
        let selectedSchedule = availabilitySchedules[indexOfSelectedDate()]
        if let index = selectedSchedule.timeslots.index(where: { (timeslot) -> Bool in
            timeslot.time == self.selectedTimeslot
        }) {
            if index < selectedSchedule.timeslots.count {
                return index
            }
        }
        return 0
    }
    
    func selectedSchedule() -> String {
        if let _ = selectedTimeslot {
            return "\(selectedTimeslot!.stringWithFormat(format: DateFormat.date.rawValue)) \(selectedTimeslot!.stringWithFormat(format: DateFormat.time.rawValue))"
        }
        
        return ""
    }
    
    // MARK: Helper methods
    
    func didSelectScheduleAtIndex(index: Int) {
        if index < availabilitySchedules.count {
            selectedTimeslot = availabilitySchedules[index].timeslots.filter { $0.availability == .available }.first?.time
        }
    }
    
    func didSelectTimeslotAtIndex(index: Int) {
        let currentSchedule = availabilitySchedules[indexOfSelectedDate()]
        if index < currentSchedule.timeslots.count {
            selectedTimeslot = currentSchedule.timeslots[index].time
        }
    }
    
    func canSelectTimeslotAtIndex(index: Int) -> Bool {
        let currentSchedule = availabilitySchedules[indexOfSelectedDate()]
        return currentSchedule.timeslots[index].availability == .available
    }
    
    
}
