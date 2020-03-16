//
//  GregorianCommonTimetable
//  GregorianHoursOfDay.swift
//
//  Created by Valeriano Della Longa on 16/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import Foundation

/// An `OptionSet ` representing the hours of the day for the gregorian calendar.
public struct GregorianHoursOfDay: OptionSet {
    public let rawValue: UInt
    
    static let everyHourRawValue: UInt = {
        
        return Array(0...23).reduce(0, { $0 | (1 << $1) }) as UInt
    }()
    
    public init(rawValue: UInt) {
        guard
            rawValue <= GregorianHoursOfDay.everyHourRawValue
            else {
                self = GregorianHoursOfDay()
                
                return
        }
        
        self.rawValue = rawValue
    }
    
    public static let midnight = GregorianHoursOfDay(rawValue: 1 << 0)
    public static let am12 =     GregorianHoursOfDay.midnight
    public static let am1  =     GregorianHoursOfDay(rawValue: 1 << 1)
    public static let am2  =     GregorianHoursOfDay(rawValue: 1 << 2)
    public static let am3  =     GregorianHoursOfDay(rawValue: 1 << 3)
    public static let am4  =     GregorianHoursOfDay(rawValue: 1 << 4)
    public static let am5  =     GregorianHoursOfDay(rawValue: 1 << 5)
    public static let am6  =     GregorianHoursOfDay(rawValue: 1 << 6)
    public static let am7  =     GregorianHoursOfDay(rawValue: 1 << 7)
    public static let am8  =     GregorianHoursOfDay(rawValue: 1 << 8)
    public static let am9  =     GregorianHoursOfDay(rawValue: 1 << 9)
    public static let am10 =     GregorianHoursOfDay(rawValue: 1 << 10)
    public static let am11 =     GregorianHoursOfDay(rawValue: 1 << 11)
    public static let noon =     GregorianHoursOfDay(rawValue: 1 << 12)
    public static let pm12 =     GregorianHoursOfDay.noon
    public static let pm1  =     GregorianHoursOfDay(rawValue: 1 << 13)
    public static let pm2  =     GregorianHoursOfDay(rawValue: 1 << 14)
    public static let pm3  =     GregorianHoursOfDay(rawValue: 1 << 15)
    public static let pm4  =     GregorianHoursOfDay(rawValue: 1 << 16)
    public static let pm5  =     GregorianHoursOfDay(rawValue: 1 << 17)
    public static let pm6  =     GregorianHoursOfDay(rawValue: 1 << 18)
    public static let pm7  =     GregorianHoursOfDay(rawValue: 1 << 19)
    public static let pm8  =     GregorianHoursOfDay(rawValue: 1 << 20)
    public static let pm9  =     GregorianHoursOfDay(rawValue: 1 << 21)
    public static let pm10 =     GregorianHoursOfDay(rawValue: 1 << 22)
    public static let pm11 =     GregorianHoursOfDay(rawValue: 1 << 23)
    
    
    public static let am: GregorianHoursOfDay = [.midnight, .am1, .am2, .am3, .am4, .am5, .am6, .am7, .am8, .am9, .am10, .am11]
    public static let pm: GregorianHoursOfDay = [.noon, .pm1, .pm2, .pm3, .pm4, .pm5, .pm6, .pm7, .pm8, .pm9, .pm10, .pm11]
    public static let everyHour: GregorianHoursOfDay = [.am, .pm]
}

extension GregorianHoursOfDay {
    public var onScheduleValues: Set<Int> {
        guard !(self.rawValue == 0) else { return [] }
        
        guard !(self == .everyHour) else { return Set(GregorianCommonTimetable.Kind.hourlyBased.rangeOfScheduleValues) }
        
        return (0..<24)
            .reduce(Set<Int>()) { partialResult, shift in
                let candidate = Self(rawValue: 1 << shift)
                guard self.contains(candidate) else {
                    return partialResult
                }
            
                var nextResult = partialResult
                nextResult.insert(shift)
            
                return nextResult
        }
    }
}
