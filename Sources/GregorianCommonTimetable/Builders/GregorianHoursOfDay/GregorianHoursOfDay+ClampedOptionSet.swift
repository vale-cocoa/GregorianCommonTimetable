//
//  GregorianCommonTimetable
//  GregorianHoursOfDay+Clamped.swift
//  
//  Created by Valeriano Della Longa on 16/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import Foundation
import ClampedOptionSet

extension GregorianHoursOfDay: ClampedOptionSet {
    public static var maxRawValue: UInt {
        
        return GregorianHoursOfDay.everyHourRawValue
    }
}

extension GregorianHoursOfDay: StringClamped, CustomStringConvertible {
    public static var allBaseValidMembersAsStrings: [String] {
        let base: [Int] = [12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
        let amStrings: [String] = base.map { GregorianHoursOfDay.hourString(for: $0)! }
        let pmStrings: [String] = base.map { GregorianHoursOfDay.hourString(for: $0, am: false)! }
        
        return amStrings + pmStrings
    }
    
    public static var validRawValueForString: (String) -> UInt? {
        
        return { name in
            guard
                let shift = GregorianHoursOfDay.shift(from: name)
                else { return nil }
            
            return 1 << shift
        }
    }
    
    // MARK: - StringClamped helpers
    private static func hourString(for hour: Int, am: Bool = true) -> String? {
        guard
            1...12 ~= hour
            else { return nil }
        
        let baseString = String(hour)
        let hourString = baseString.count == 1 ? ("0" + baseString) : baseString
        
        return am == true ? (hourString + ":00am") : (hourString + ":00pm")
    }
    
    private static func shift(from string: String) -> Int? {
        let baseComp = string.components(separatedBy: ":")
        guard
            baseComp.count == 2,
            baseComp.first!.count == 2,
            baseComp.last!.count == 4,
            let hoursComp = Int(baseComp.first!),
            1...12 ~= hoursComp
            else { return nil }
        
        let minutesString = baseComp.last!.prefix(2)
        let meridianString = baseComp.last!.suffix(2)
        guard
            let minutesComp = Int(minutesString),
            0...59 ~= minutesComp,
            let idx = ["am", "pm"].firstIndex(where: {
                
                return $0.caseInsensitiveCompare(meridianString) == .orderedSame
            })
            else { return nil }
        
        return ( (hoursComp % 12) + (idx * 12) )
    }
}

extension GregorianHoursOfDay: CalendricClamped {
    public static var validRawValueForDate: (Date) -> UInt {
        
        return { date in
            let shift = Calendar.gregorianCalendar.component(.hour, from: date)
            
            return (1 << shift)
        }
    }
}
