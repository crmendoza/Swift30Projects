//
//  Date+ScheduleSelector.swift
//  ScheduleSelector
//
//  Created by Mendoza, Christine Roanne
//  Copyright © 2018 Mendoza, Christine Roanne. All rights reserved.
//

import Foundation

extension Date {
    func stringWithFormat(format: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
