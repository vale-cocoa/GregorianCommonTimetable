//
//  GregorianCommonTimetable
//  GregorianDays.swift
//
//  Created by Valeriano Della Longa on 16/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import Foundation

/// An `OptionSet ` representing the hours of the day for the gregorian calendar.
public struct GregorianDays: OptionSet {
    public let rawValue: UInt
    
    static let everyDayRawValue: UInt = {
        
        return Array(0...30).reduce(0, { $0 | (1 << $1) }) as UInt
    }()
    
    public init(rawValue: UInt) {
        guard
            rawValue <= Self.everyDayRawValue
            else {
                self = Self()
                
                return
        }
        
        self.rawValue = rawValue
    }
    
    public static let first = Self(rawValue: 1 << 0)
    public static let second = Self(rawValue: 1 << 1)
    public static let third = Self(rawValue: 1 << 2)
    public static let fourth = Self(rawValue: 1 << 3)
    public static let fifth = Self(rawValue: 1 << 4)
    public static let sixth = Self(rawValue: 1 << 5)
    public static let seventh = Self(rawValue: 1 << 6)
    public static let eighth = Self(rawValue: 1 << 7)
    public static let nineth = Self(rawValue: 1 << 8)
    public static let tenth = Self(rawValue: 1 << 9)
    public static let eleventh = Self(rawValue: 1 << 10)
    public static let twelveth = Self(rawValue: 1 << 11)
    public static let thirteenth = Self(rawValue: 1 << 12)
    public static let fouteenth = Self(rawValue: 1 << 13)
    public static let fifteenth = Self(rawValue: 1 << 14)
    public static let sixteenth = Self(rawValue: 1 << 15)
    public static let seventeenth = Self(rawValue: 1 << 16)
    public static let eighteenth = Self(rawValue: 1 << 17)
    public static let nineteenth = Self(rawValue: 1 << 18)
    public static let twentieth = Self(rawValue: 1 << 19)
    public static let twentyFirst = Self(rawValue: 1 << 20)
    public static let twentySecond = Self(rawValue: 1 << 21)
    public static let twentyThird = Self(rawValue: 1 << 22)
    public static let twentyFourth = Self(rawValue: 1 << 23)
    public static let twentyFifth = Self(rawValue: 1 << 24)
    public static let twentySixth = Self(rawValue: 1 << 25)
    public static let twentySeventh = Self(rawValue: 1 << 26)
    public static let twentyEigth = Self(rawValue: 1 << 27)
    public static let twentyNineth = Self(rawValue: 1 << 28)
    public static let thirtieth = Self(rawValue: 1 << 29)
    public static let thirtyFirst = Self(rawValue: 1 << 30)
    
    public static let lastMonthDay = Self(rawValue: 1 << 30)
    
    public static let everyDay = Self(rawValue: Self.everyDayRawValue)
}

extension GregorianDays {
    public var onScheduleValues: Set<Int> {
        guard self.rawValue != 0 else { return [] }
        
        guard
            self.rawValue != Self.everyDayRawValue
            else { return Set(GregorianCommonTimetable.Kind.dailyBased.rangeOfScheduleValues) }
        
        return (0..<31).reduce(Set<Int>()) { partialResult, shift in
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
