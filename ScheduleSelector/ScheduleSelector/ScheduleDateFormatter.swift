//
//  ScheduleDateFormatter.swift
//  ScheduleSelector
//
//  Created by Mendoza, Christine Roanne
//  Copyright © 2018 Mendoza, Christine Roanne. All rights reserved.
//

import Foundation

class ScheduleDateFormatter {
    static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withFullTime, .withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime, .withFractionalSeconds]
        return formatter
    }()
}

