//
//  GregorianCommonTimetable
//  GregorianCommonTimetable+Generators.swift
//
//  Created by Valeriano Della Longa on 18/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import Foundation
import Schedule
import VDLCalendarUtilities
import VDLGCDHelpers

// MARK: - scheduleGenerator
extension GregorianCommonTimetable {
    static func scheduleGenerator(kind: Kind,
        for scheduledValues: Set<Int>
    ) throws
        -> Schedule.Generator
    {
        guard
            scheduledValues.isSubset(of: Set(kind.rangeOfScheduleValues))
            else { throw Error.scheduleValueOutOfRange }
        
        guard !scheduledValues.isEmpty else { return emptyGenerator }
        
        return { [scheduledValues, kind] date, direction in
            guard
                let shift = shiftValue(for: date, in: scheduledValues, of: kind, to: direction)
                else { return nil }
            
            guard
                shift != 0
                else {
                    return Calendar.gregorianCalendar.dateInterval(of: kind.durationComponent, for: date)
            }
            
            guard
                let onDate = Calendar.gregorianCalendar.date(byAdding: kind.durationComponent, value: shift, to: date)
                else { return nil }
            
            return Calendar.gregorianCalendar.dateInterval(of: kind.durationComponent, for: onDate)
        }
    }
    
}

// MARK: - scheduleAsyncGenerator
extension GregorianCommonTimetable {
    static func scheduleAsyncGenerator(
        kind: Kind,
        for scheduledValues: Set<Int>
    ) throws
        -> Schedule.AsyncGenerator
    {
        let scheduleGenerator = try Self.scheduleGenerator(kind: kind, for: scheduledValues)
        
        guard !isEmptyGenerator(scheduleGenerator)
            else {
                
                return { dateInterval, queue, completion in
                    DispatchQueue.global(qos: .userInitiated).async {
                        dispatchResultCompletion(result: .success([]), queue: queue, completion: completion)
                    }
                }
        }
        
        return { dateInterval, queue, completion in
            DispatchQueue.global(qos: .userInitiated).async {
                var result: Result<[DateInterval], Swift.Error>!
                do {
                    let elements = try scheduleElements(for: scheduleGenerator, of: kind, in: dateInterval)
                    result = .success(elements)
                } catch {
                    result = .failure(error)
                }
                dispatchResultCompletion(result: result, queue: queue, completion: completion)
            }
        }
    }
    
}
