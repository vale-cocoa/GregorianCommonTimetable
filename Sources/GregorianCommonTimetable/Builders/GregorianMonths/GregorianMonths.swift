//
//  GregorianMonths.swift
//
//
//  Created by Valeriano Della Longa on 24/01/2020.
//

import Foundation

/// An OptionSet representing the Gregorian Calendar months.
public struct GregorianMonths: OptionSet {
    public let rawValue: UInt

    static var everyMonthRawValue: UInt {

        return Array(0...11).reduce(0, {$0 | (1 << $1)}) as UInt
    }

    public init(rawValue: UInt) {
        guard rawValue <= GregorianMonths.everyMonthRawValue else {
            self = GregorianMonths()

        return
        }
        self.rawValue = rawValue
    }

    public static let january =     GregorianMonths(rawValue: 1 << 0)
    public static let february =    GregorianMonths(rawValue: 1 << 1)
    public static let march =       GregorianMonths(rawValue: 1 << 2)
    public static let april =       GregorianMonths(rawValue: 1 << 3)
    public static let may =         GregorianMonths(rawValue: 1 << 4)
    public static let june =        GregorianMonths(rawValue: 1 << 5)
    public static let july =        GregorianMonths(rawValue: 1 << 6)
    public static let august =      GregorianMonths(rawValue: 1 << 7)
    public static let september =   GregorianMonths(rawValue: 1 << 8)
    public static let october =     GregorianMonths(rawValue: 1 << 9)
    public static let november =    GregorianMonths(rawValue: 1 << 10)
    public static let december =    GregorianMonths(rawValue: 1 << 11)

    public static let firstQuarter: GregorianMonths =   [.january, .february, .march]
    public static let secondQuarter: GregorianMonths =  [.april, .may, .june]
    public static let thirdQuarter: GregorianMonths =   [.july, .august, .september]
    public static let fourthQuarter: GregorianMonths =  [.october, .november, .december]

    public static let firstHalf: GregorianMonths =      [.firstQuarter, .secondQuarter]
    public static let secondHalf: GregorianMonths =     [.thirdQuarter, .fourthQuarter]

    public static let year: GregorianMonths =           [.firstHalf, .secondHalf]
}

extension GregorianMonths {
    public var onScheduleValues: Set<Int> {
        guard !(self.rawValue == 0) else { return [] }
        
        guard !(self == .year) else { return Set(GregorianCommonTimetable.Kind.monthlyBased.rangeOfScheduleValues) }
        
        return (0..<12)
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

extension GregorianMonths: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.rawValue)
    }
    
}
