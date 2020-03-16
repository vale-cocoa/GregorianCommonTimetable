//
//  GregorianCommonTimetable
//  GregorianWeekdays.swift
//  
//  Created by Valeriano Della Longa on 16/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import Foundation


/// An `OptionSet` representing the gregorian calendar weekdays.
public struct GregorianWeekdays: OptionSet {
    public let rawValue: UInt

    static var everydayRawValue: UInt {

        return Array(0...6).reduce(0, { $0 | (1 << $1) }) as UInt
    }

    public init(rawValue: UInt) {
        guard
            rawValue <= GregorianWeekdays.everydayRawValue
            else {
                self = GregorianWeekdays()
                
                return
        }
        
        self.rawValue = rawValue
    }

    public static let sunday =      GregorianWeekdays(rawValue: 1 << 0)
    public static let monday =      GregorianWeekdays(rawValue: 1 << 1)
    public static let tuesday =     GregorianWeekdays(rawValue: 1 << 2)
    public static let wednesday =   GregorianWeekdays(rawValue: 1 << 3)
    public static let thursday =    GregorianWeekdays(rawValue: 1 << 4)
    public static let friday =      GregorianWeekdays(rawValue: 1 << 5)
    public static let saturday =    GregorianWeekdays(rawValue: 1 << 6)

    public static let weekend: GregorianWeekdays =  [.saturday, .sunday]
    public static let weekdays: GregorianWeekdays = [.monday, .tuesday, .wednesday, .thursday, .friday]
    public static let everyday: GregorianWeekdays = [.weekdays, .weekend]
}

extension GregorianWeekdays {
    public var onScheduleValues: Set<Int> {
        guard !(self.rawValue == 0) else { return [] }
        
        guard !(self == .everyday) else { return Set(GregorianCommonTimetable.Kind.weekdayBased.rangeOfScheduleValues) }
        
        return (0..<7)
            .reduce(Set<Int>()) { partialResult, shift in
                let candidate = Self(rawValue: 1 << shift)
                guard self.contains(candidate) else {
                    return partialResult
                }
            
                var nextResult = partialResult
                nextResult.insert(shift + 1)
            
                return nextResult
        }
    }
}
