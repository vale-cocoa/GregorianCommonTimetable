//
//  GregorianMonths+ClampedOptionSet.swift
//  
//
//  Created by Valeriano Della Longa on 24/01/2020.
//

import Foundation
import ClampedOptionSet

extension GregorianMonths: ClampedOptionSet {
    public static var maxRawValue: UInt {

        return GregorianMonths.everyMonthRawValue
    }
}

extension GregorianMonths: StringClamped, CustomStringConvertible {
    public static var allBaseValidMembersAsStrings: [String] {

        return Calendar.gregorianCalendar.monthSymbols
    }

    /**
    GregorianMonths struct will try to get a valid RawValue from a string by doing caseInsensitive compares to elements of both monthSymbols and shortMonthSymbols properties of Calendar.gregorianCalendar.
    For example: "Jan", "January" and all their case variants equivalents will map to the rawValue for .january
    */
    public static var validRawValueForString: (String) -> UInt? {

        return { name in
            guard
                let shift = Calendar.gregorianCalendar.monthSymbols
                    .firstIndex(where: {
                    
                    return name.caseInsensitiveCompare($0) == .orderedSame
                }) ??
                    Calendar.gregorianCalendar.shortMonthSymbols
                        .firstIndex(where: {
                        
                        return name.caseInsensitiveCompare($0) == .orderedSame
                })
                else {
                    if name.caseInsensitiveCompare("firstQuarter") == .orderedSame {
                        
                        return GregorianMonths.firstQuarter.rawValue
                    } else if name.caseInsensitiveCompare("secondQuarter") == .orderedSame {
                        
                        return GregorianMonths.secondQuarter.rawValue
                    } else if name.caseInsensitiveCompare("thirdQuarter") == .orderedSame {
                        
                        return GregorianMonths.thirdQuarter.rawValue
                    } else if name.caseInsensitiveCompare("fourthQuarter") == .orderedSame {
                        
                        return GregorianMonths.fourthQuarter.rawValue
                    } else if name.caseInsensitiveCompare("firstHalf") == .orderedSame {
                        
                        return GregorianMonths.firstHalf.rawValue
                    } else if name.caseInsensitiveCompare("secondHalf") == .orderedSame {
                        
                        return GregorianMonths.secondHalf.rawValue
                    } else if name.caseInsensitiveCompare("year") == .orderedSame {
                        
                        return GregorianMonths.maxRawValue
                    }

                return nil
            }

            return 1 << shift
        }
    }
}

extension GregorianMonths: CalendricClamped {
    public static var validRawValueForDate: (Date) -> UInt {

        return {date in
            let shift = (Calendar.gregorianCalendar.component(.month, from: date) - 1)

            return (1 << shift)
        }
    }
}
