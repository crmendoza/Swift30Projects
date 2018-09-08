//
//  Timeslot.swift
//  ScheduleSelector
//
//  Created by Mendoza, Christine Roanne
//  Copyright © 2018 Mendoza, Christine Roanne. All rights reserved.
//

import Foundation

enum Status: String {
    case available = "available"
    case unavailable = "not_available"
}

struct Timeslot {
    let time: Date
    let availability: Status
    let duration: Int
    
    init(time: Date, availability: Status, duration: Int) {
        self.time = time
        self.availability = availability
        self.duration = duration
    }
}

extension  Timeslot: Decodable {
    enum TimeslotSructKeys: String, CodingKey {
        case time = "startTime"
        case duration = "duration"
        case availability = "status"
    }
    
    init(from decoder: Decoder) throws {
        let container =  try decoder.container(keyedBy: TimeslotSructKeys.self)
        let timeString = try container.decode(String.self, forKey: .time)
        let dateTime = ScheduleDateFormatter.iso8601.date(from: timeString)!
        let duration = try container.decode(Int.self, forKey: .duration)
        let availability = try container.decode(String.self, forKey: .availability)
        
        self.init(time: dateTime, availability: Status.init(rawValue: availability)!, duration: duration)
    }
}
