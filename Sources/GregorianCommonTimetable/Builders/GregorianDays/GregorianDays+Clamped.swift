//
//  GregorianCommonTimetable
//  GregorianDays+Clamped.swift
//
//  Created by Valeriano Della Longa on 16/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import Foundation
import ClampedOptionSet

extension GregorianDays: ClampedOptionSet {
    public static var maxRawValue: UInt {
        return Self.everyDayRawValue
    }
}

extension GregorianDays: StringClamped, CustomStringConvertible {
    public static var allBaseValidMembersAsStrings: [String]
    {
        return (1...31)
            .map { String($0) }
    }
    
    public static var validRawValueForString: (String) -> UInt? {
        
        return { dayString in
            if
                let asInt = Int(dayString),
                (1..<32).contains(asInt)
            {
                let shift = asInt - 1
                return UInt(1 << shift)
            }
            
            return nil
        }
    }
    
}

extension GregorianDays: CalendricClamped {
    public static var validRawValueForDate: (Date) -> UInt {
        
        return { date in
            let day = Calendar.gregorianCalendar.component(.day, from: date)
            let shift = day - 1
            
            return 1 << shift
        }
    }
    
    public func contains(date: Date) -> Bool {
        let day = Calendar.gregorianCalendar.component(.day, from: date)
        let dayAsGreg = Self(rawValue: UInt(1 << (day - 1)))
        guard
            !self.contains(dayAsGreg)
            else { return true }
        
        if
            self.contains(.lastMonthDay),
            let rangeOfDays = Calendar.gregorianCalendar.range(of: .day, in: .month, for: date),
            day == rangeOfDays.last!
        {
            
            return true
        }
        
        return false
    }
    
}
