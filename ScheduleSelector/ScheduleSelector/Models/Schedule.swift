//
//  Schedule.swift
//  ScheduleSelector
//
//  Created by Mendoza, Christine Roanne
//  Copyright © 2018 Mendoza, Christine Roanne. All rights reserved.
//

import Foundation

struct Schedule {
    let date: Date
    let timeslots: [Timeslot]
    
    init(date: Date, timeslots: [Timeslot]) {
        self.date = date
        self.timeslots = timeslots
    }
}

extension Schedule: Decodable {
    enum ScheduleStructKeys: String, CodingKey {
        case date = "date"
        case timeslots = "timeslots"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ScheduleStructKeys.self)
        let dateString: String = try container.decode(String.self, forKey: .date)
        let date = dateFromString(dateString: dateString)!
        let timeslots: [Timeslot] = try container.decode([Timeslot].self, forKey: .timeslots)
        
        self.init(date: date, timeslots: timeslots)
    }
}

fileprivate func dateFromString(dateString: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd"
    let date = dateFormatter.date(from:dateString)!
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month, .day, .weekday], from: date)
    let finalDate = calendar.date(from:components)
    return finalDate
}
