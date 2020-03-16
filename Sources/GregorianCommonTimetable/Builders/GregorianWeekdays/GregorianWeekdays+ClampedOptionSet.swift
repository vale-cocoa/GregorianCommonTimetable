//
//  GregorianCommonTimetable
//  GregorianWeekdays+ClampedOptionSet.swift
//  
//  Created by Valeriano Della Longa on 22/01/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import Foundation
import ClampedOptionSet

extension GregorianWeekdays: ClampedOptionSet {
    public static var maxRawValue: UInt {

        return GregorianWeekdays.everydayRawValue
    }

}


extension GregorianWeekdays: StringClamped, CustomStringConvertible {
    public static var allBaseValidMembersAsStrings: [String] {

        return Calendar.gregorianCalendar.weekdaySymbols
    }

    /// `GregorianWeekdays` struct will try to get a valid `RawValue` from a `String` by doing `caseInsensitive` compares to elements of both `weekdaySymbols` and `shortWeekdaySymbols` properties of `Calendar.gregorianCalendar`.
    ///
    /// For example: `"Mon"`, `"Monday"` and all their case variants equivalents will map
    /// to the `rawValue` for `.monday`.
    public static var validRawValueForString: (String) -> UInt? {

        return { name in
            guard
                let shift = Calendar.gregorianCalendar.weekdaySymbols.firstIndex(where: {
                    
                    return name.caseInsensitiveCompare($0) == .orderedSame
                }) ?? Calendar.gregorianCalendar.shortWeekdaySymbols.firstIndex(where: {
                    
                    return name.caseInsensitiveCompare($0) == .orderedSame
                })
                else {
                    if name.caseInsensitiveCompare("weekend") == .orderedSame {
                        
                        return GregorianWeekdays.weekend.rawValue
                    } else if name.caseInsensitiveCompare("weekdays") == .orderedSame {
                        
                        return GregorianWeekdays.weekdays.rawValue
                    } else if name.caseInsensitiveCompare("everyday") == .orderedSame {
                        
                        return GregorianWeekdays.maxRawValue
                    }
                    
                    return nil
            }

            return (1 << shift)
        }
    }
    
}

extension GregorianWeekdays: CalendricClamped {
    public static var validRawValueForDate: (Date) -> UInt {

        return { date in
            let shift = Calendar.gregorianCalendar.component(.weekday, from: date) - 1

            return (1 << shift)
        }
    }

}
