//
//  GregorianCommonTimetable
//  GregorianCommonTimetable+CustomStringConvertible.swift
//  
//  Created by Valeriano Della Longa on 03/04/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import Foundation
extension GregorianCommonTimetable: CustomStringConvertible {
    public var description: String {
        let underlaying: String!
        switch self.kind {
        case .hourlyBased:
            let hours = GregorianHoursOfDay(rawValue: rawValueOfBuilder)
            underlaying = hours.description
        case .weekdayBased:
            let weekdays = GregorianWeekdays(rawValue: rawValueOfBuilder)
            underlaying = weekdays.description
        case .dailyBased:
            let days = GregorianDays(rawValue: rawValueOfBuilder)
            underlaying = days.description
        case .monthlyBased:
            let months = GregorianMonths(rawValue: rawValueOfBuilder)
            underlaying = months.description
        }
        
        return "GregorianCommonTimeTable(\(underlaying!))"
    }
    
}
